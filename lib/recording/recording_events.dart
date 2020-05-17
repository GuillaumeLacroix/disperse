import 'package:disperse/animation/shapes_utilities.dart';
import 'package:disperse/util/configuration.dart';
import 'package:flutter/material.dart';

abstract class RecordingEvent {
  DateTime time;

  RecordingEvent(this.time);

  Map<String, dynamic> toJson() {
    return {'time': time.toIso8601String()};
  }

  RecordingEvent.fromMap(Map<String, dynamic> map) {
    time = DateTime.parse(map['time']);
  }
}

class PaintingEvent extends RecordingEvent {
  Shape shape;
  Color color;
  double radius;
  Offset position;
  int maskIndex;

  PaintingEvent(DateTime time, this.shape, this.color, this.radius,
      this.position, this.maskIndex)
      : super(time);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = super.toJson();
    res.addAll({
      'shape': shape.index,
      'color': color.value,
      'radius': radius,
      'position': (position.dx / Configuration.screenWidth).toString() +
          '/' +
          (position.dy / Configuration.screenHeight).toString(),
      'maskIndex': maskIndex,
    });
    return res;
  }

  PaintingEvent.fromMap(Map<String, dynamic> map) : super.fromMap(map) {
    shape = Shape.values[map['shape']];
    color = Color(map['color']);
    radius = map['radius'];
    maskIndex = map['maskIndex'];

    String fullPos = map['position'];
    int index = fullPos.indexOf('/');

    position = Offset(double.parse(fullPos.substring(0, index)) * Configuration.screenWidth,
        double.parse(fullPos.substring(index + 1)) * Configuration.screenHeight);
  }
}

class BackgroundChangeEvent extends RecordingEvent {
  int backgroundImageIndex;

  BackgroundChangeEvent(DateTime time, this.backgroundImageIndex) : super(time);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = super.toJson();
    res.addAll({
      'backgroundImageIndex': backgroundImageIndex,
    });
    return res;
  }

  BackgroundChangeEvent.fromMap(Map<String, dynamic> map) : super.fromMap(map) {
    backgroundImageIndex = map['backgroundImageIndex'];
  }
}
