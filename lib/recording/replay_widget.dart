import 'dart:async';

import 'package:disperse/animation/background_utilities.dart';
import 'package:disperse/animation/shapes_utilities.dart';
import 'package:disperse/recording/recording_events.dart';
import 'package:disperse/shapes/circle_painter.dart';
import 'package:disperse/shapes/square_painter.dart';
import 'package:disperse/shapes/triangle_painter.dart';
import 'package:disperse/util/configuration.dart';
import 'package:flutter/material.dart';

import '../main_panel.dart';

class ReplayWidget extends StatelessWidget {
  static const String ROUTE_NAME = '/replay';

  @override
  Widget build(BuildContext context) {
    final Map<Duration, RecordingEvent> args = ModalRoute.of(context).settings.arguments;

    return Scaffold(body: _ReplayWidget(events: args));
  }
}

class _ReplayWidget extends StatefulWidget {
  final Map<Duration, RecordingEvent> events;

  const _ReplayWidget({Key key, @required this.events}) : super(key: key);

  @override
  _ReplayWidgetState createState() => _ReplayWidgetState();
}

class _ReplayWidgetState extends State<_ReplayWidget>
    with ShapeClickable<_ReplayWidget> {
  AssetImage image;

  List<Timer> timers;

  _ReplayWidgetState() {
    timers = [];
    widgets = [];
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => init());
  }

  void init() {
    Duration max;
    widget.events.forEach((duration, event) {
      if (event is PaintingEvent) {
        timers.add(Timer(duration, () {
          click(event);
        }));
        if (max == null || max.compareTo(duration) < 0) {
          max = duration;
        }
      } else if (event is BackgroundChangeEvent) {
        timers.add(Timer(duration, () {
          image = BackgroundUtilities.getBackground(event.backgroundImageIndex);
          setState(() {});
        }));
        if (max == null || max.compareTo(duration) < 0) {
          max = duration;
        }
      }
    });
    timers.add(Timer(
        Duration(milliseconds: max.inSeconds * 1000 + Configuration.AFTER_REPLAY_WAIT_TIME),
        () {
      Navigator.of(context).pop();
    }));
  }

  @override
  void dispose() {
    super.dispose();
    timers.forEach((timer) => timer.cancel());
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: ShapeDisplayWidget(image, widgets));
  }
}

mixin ShapeClickable<T extends StatefulWidget> on State<T> {
  List<Widget> widgets;

  void click(PaintingEvent event) {
    void listener(Widget widget) {
      setState(() {
        widgets.remove(widget);
      });
    }

    switch (event.shape) {
      case Shape.CIRCLE:
        widgets.add(CircleAnimator(
          event.position,
          listener,
          event.color,
          event.radius,
          event.maskIndex,
          key: UniqueKey(),
        ));
        break;
      case Shape.SQUARE:
        widgets.add(SquareAnimator(
          event.position,
          listener,
          event.color,
          event.radius,
          event.maskIndex,
          key: UniqueKey(),
        ));
        break;
      case Shape.TRIANGLE:
        widgets.add(TriangleAnimator(event.position, listener, event.color,
            event.radius, event.maskIndex,
            key: UniqueKey()));
        break;
    }
    setState(() {});
  }
}
