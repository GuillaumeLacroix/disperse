import 'dart:async';
import 'dart:io';

import 'package:disperse/recording/recorder.dart';
import 'package:disperse/recording/recording_events.dart';
import 'package:disperse/recording/replay_manager.dart';
import 'package:disperse/recording/replay_metadata.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class RecordingSaver {
  static const String _BGE_ID = 'BackgroundEvent - ';
  static const String _PE_ID = 'PictureEvent - ';
  static const String EXTENSION = '.disp';

  static final RecordingSaver _singleton = RecordingSaver._internal();
  factory RecordingSaver() => _singleton;
  RecordingSaver._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> _getLocalFile(String name) async {
    final path = await _localPath;
    getDirectory(path); // Create the directory if necessary
    File f = File('$path/recordings/$name$EXTENSION');
    return f;
  }

  Directory getDirectory(String path) {
    Directory folder = Directory('$path/recordings');
    if (!folder.existsSync()) {
      folder.createSync();
    }
    return folder;
  }

  Future<List<ReplayMetadata>> listFiles() async {
    Directory directory = Directory(await _localPath + '/recordings');
    if (!await directory.exists()) {
      return [];
    } else {
      List<ReplayMetadata> result = [];
      return dirContents(directory).then((fses) => fses.forEach((fse) async {
            String path = fse.path;
            // Get the file name
            String fileName = path.substring(path.lastIndexOf('/') + 1);
            // Remove extension
            fileName =
                fileName.substring(0, fileName.length - EXTENSION.length);
            File file = await _getLocalFile(fileName);
            String firstLine = file.readAsLinesSync()[0];
            DateTime from = DateTime.fromMillisecondsSinceEpoch(
                int.parse(firstLine.substring(0, firstLine.indexOf('-'))));
            int bgIndex =
                int.parse(firstLine.substring(firstLine.indexOf('-') + 1));
            result.add(ReplayMetadata()
              ..date = from
              ..bgIndex = bgIndex
              ..isSaved = true
              ..title = fileName);
          })).then((_) {
        return result;
      }).catchError((error, stacktrace) => print('$error $stacktrace'));
    }
  }

  Future<List<FileSystemEntity>> dirContents(Directory dir) {
    return dir.list(recursive: false).toList();
  }

  String getFileName(DateTime from) {
    return '${DateFormat('dd_MM_yyyy_HH_mm_ss').format(from)}';
  }

  String getFileNameFromPath(String path) {
    return path.substring(path.lastIndexOf('/') + 1);
  }

  Future<bool> deleteFile(ReplayMetadata rm) async {
    return _getLocalFile(rm.title)
        .then((file) => file.delete())
        .then((_) => ReplayManager().removeMetadata(rm))
        .then((_) => true);
  }

  Future<File> writeEventList<T extends RecordingEvent>(
      ReplayMetadata rm, List<T> events,
      {Directory directory}) async {
    File file = directory == null
        ? await _getLocalFile(getFileName(rm.date))
        : File(directory.uri.path + rm.title + EXTENSION);

    DateTime from = rm.date;
    int bgImageIndex = rm.bgIndex;

    if (await file.exists()) {
      throw 'File already exists!';
    }
    file.create();

    String finalString =
        '${from.millisecondsSinceEpoch.toString()}-$bgImageIndex';
    events.forEach((T event) {
      String tmp;
      if (event is BackgroundChangeEvent) {
        tmp = _BGE_ID;
      } else if (event is PaintingEvent) {
        tmp = _PE_ID;
      }
      tmp += jsonEncode(event.toJson());
      finalString += '\n$tmp';
    });

    String title = getFileNameFromPath(file.path);
    title = title.substring(0, title.length - EXTENSION.length);
    return file
        .writeAsString(finalString)
        .whenComplete(() => directory == null ? ReplayManager().addMetadata(rm..title ??= title) : null);
  }

  Future<Map<Duration, RecordingEvent>> getEventsFrom(String fileName) async {
    File file = await _getLocalFile(fileName);

    List<RecordingEvent> events = [];
    List<String> lines = await file.readAsLines();

    DateTime from;
    lines.forEach((line) {
      if (line.startsWith(_BGE_ID)) {
        events.add(BackgroundChangeEvent.fromMap(
            json.decode(line.substring(_BGE_ID.length))));
      } else if (line.startsWith(_PE_ID)) {
        events.add(
            PaintingEvent.fromMap(json.decode(line.substring(_PE_ID.length))));
      } else {
        from = DateTime.fromMillisecondsSinceEpoch(int.parse(line.substring(0, line.lastIndexOf('-'))));
      }
    });

    return Replay().getReplay(from, events);
  }

  Future shareFile(ReplayMetadata rm) async {
    if (rm.isSaved) {
      String fileName = rm.title;
      File file = await _getLocalFile(fileName);
      return Share.file('Share recording $fileName', '$fileName$EXTENSION',
          file.readAsBytesSync(), '*/*');
    } else {
      final directory = await Directory.systemTemp.createTemp();
      print(directory.uri.path);
      rm.title = getFileName(rm.date);
      File file = await writeEventList(rm, Recorder().getReplayFrom(rm.date),
          directory: directory);
      return Share.file(
          'Share recording ${rm.title}',
          '${getFileNameFromPath(file.path)}$EXTENSION',
          file.readAsBytesSync(),
          '*/*');
    }
  }

  Future<dynamic> ingestFile() async {
    File file = await FilePicker.getFile(
        allowedExtensions: [EXTENSION.substring(1)], type: FileType.custom);
    if (file == null) {
      return null;
    }
    Directory directory = getDirectory(await _localPath);
    String fileName = file.path.substring(file.path.lastIndexOf('/') + 1);
    String fullPath = directory.path + '/' + fileName;
    if (File(fullPath).existsSync()) {
      return false;
    }
    await file.copy(fullPath);
    ReplayManager().setMetadatas(await listFiles());
    return fileName.substring(0, fileName.length - EXTENSION.length);
  }

  Future<bool> renameFile(String previous, String newName) async {
    return _getLocalFile(previous).then((file) async {
      if ((await _getLocalFile(newName)).existsSync()) {
        return false;
      }
      return file
          .rename(
              getDirectory(await _localPath).path + '/' + newName + EXTENSION).then((_) {
                ReplayManager().updateTitle(previous, newName);
      })
          .then((_) => true);
    });
  }
}
