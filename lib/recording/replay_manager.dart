import 'package:disperse/recording/recorder.dart';
import 'package:disperse/recording/recording_events.dart';
import 'package:disperse/recording/recording_saver.dart';
import 'package:disperse/recording/replay_metadata.dart';

class ReplayManager {
  static final ReplayManager _singleton = ReplayManager._internal();
  factory ReplayManager() => _singleton;

  List<ReplayMetadata> _fileMetadatas;

  ReplayManager._internal() {
    _fileMetadatas = [];
  }

  Future init() async {
    _fileMetadatas = await RecordingSaver().listFiles();
  }

  void updateTitle(String title, String newTitle) {
    _fileMetadatas.forEach((rm) {
      if (title == rm.title) {
        rm.title = newTitle;
        return;
      }
    });
  }

  void setMetadatas(List<ReplayMetadata> metadatas) {
    _fileMetadatas = metadatas;
  }

  void addMetadata(ReplayMetadata rm) {
    _fileMetadatas.add(rm);
    rm.isSaved = true;
  }

  void removeMetadata(ReplayMetadata rm) {
    _fileMetadatas.remove(rm);
    rm.isSaved = false;
  }

  List<ReplayMetadata> getMetadatas() {
    List<ReplayMetadata> res = List.from(_fileMetadatas);
    LocalReplayManager().getRecordMetadatas().forEach((rm) {
      ReplayMetadata corresponding = _getCorrespondingMetadata(rm);
      if (corresponding == null) {
        res.add(rm);
      } else {
        corresponding.isSession = true;
      }
    });
    return res;
  }

  Future<Map<Duration, RecordingEvent>> getEvents(ReplayMetadata rm) async {
    if (rm.isSession) {
      return Replay().getReplay(rm.date, Recorder().getReplayFrom(rm.date));
    } else if (rm.isSaved) {
      return await RecordingSaver().getEventsFrom(rm.title);
    }
    return {};
  }

  ReplayMetadata _getCorrespondingMetadata(ReplayMetadata replayMetadata) {
    for (ReplayMetadata rm in _fileMetadatas) {
      if (rm.date.isAtSameMomentAs(replayMetadata.date)) {
        return rm;
      }
    }
    return null;
  }
}

class LocalReplayManager {

  static final LocalReplayManager _singleton = LocalReplayManager._internal();
  factory LocalReplayManager() => _singleton;

  LocalReplayManager._internal();

  List<ReplayMetadata> getRecordMetadatas() {
    List<ReplayMetadata> res = [];

    List<BackgroundChangeEvent> bgEvents = Recorder().bgChangeEvents;
    List<PaintingEvent> events = Recorder().paintingEvents;
    if (events.isEmpty) {
      return [];
    }

    DateTime lastTouch = events[0].time;
    int img = bgEvents
        .lastWhere((bge) => bge.time.isBefore(lastTouch))
        .backgroundImageIndex;
    res.add(ReplayMetadata()..bgIndex = img..date=lastTouch..isSession = true);
    Recorder().paintingEvents.forEach((PaintingEvent e) {
      if (!e.time.isBefore(lastTouch.add(Duration(seconds: 30)))) {
        int img = bgEvents
            .lastWhere((bge) => bge.time.isBefore(e.time))
            .backgroundImageIndex;
        res.add(ReplayMetadata()..bgIndex = img..date=e.time..isSession = true);
      }
      lastTouch = e.time;
    });
    return res;
  }

}