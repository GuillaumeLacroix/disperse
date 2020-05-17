
import 'package:disperse/recording/recording_events.dart';

class Recorder {
  static final Recorder _singleton = Recorder._internal();
  factory Recorder() => _singleton;
  Recorder._internal();

  List<PaintingEvent> _paintingEvents = [];
  List<PaintingEvent> get paintingEvents => _paintingEvents;
  List<BackgroundChangeEvent> _bgChangeEvents = [];
  List<BackgroundChangeEvent> get bgChangeEvents => _bgChangeEvents;

  void addPaintingEvent(PaintingEvent event) {
    _paintingEvents.add(event);
  }

  void addBackgroundEvent(BackgroundChangeEvent event) {
    _bgChangeEvents.add(event);
  }

  List<RecordingEvent> getReplayFrom(DateTime from) {
    List<RecordingEvent> res = [];

    List<BackgroundChangeEvent> bgEvents = _bgChangeEvents;
    List<PaintingEvent> events = _paintingEvents;

    BackgroundChangeEvent backgroundChangeEvent =
    bgEvents.lastWhere((bge) => bge.time.isBefore(from));
    res.add(backgroundChangeEvent);

    DateTime lastTouch = from;
    for (PaintingEvent paintingEvent in events) {
      DateTime eventTime = paintingEvent.time;
      if (eventTime.isBefore(from)) {
        continue;
      }
      if (!eventTime.isBefore(lastTouch.add(Duration(seconds: 30)))) {
        break;
      }

      res.add(paintingEvent);
      lastTouch = eventTime;
    }

    for (BackgroundChangeEvent backgroundChangeEvent in bgEvents) {
      DateTime eventTime = backgroundChangeEvent.time;
      if (eventTime.isBefore(from)) {
        continue;
      }
      if (eventTime.isAfter(lastTouch.add(Duration(seconds: 2)))) {
        break;
      }
      res.add(backgroundChangeEvent);
    }

    return res;
  }

}

class Replay {
  Map<Duration, RecordingEvent> getReplay(DateTime from,
      List<RecordingEvent> inputEvents) {
    Map<Duration, RecordingEvent> res = {};
    if (inputEvents.isEmpty) {
      return res;
    }

    // Subtract 2 seconds to allow for visual initialisation
    from = from.subtract(Duration(seconds: 2));

    inputEvents
        .forEach((ce) => res.putIfAbsent(ce.time.difference(from), () => ce));

    return res;
  }
}
