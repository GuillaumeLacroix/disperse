import 'dart:async';

import 'package:disperse/animation/background_utilities.dart';
import 'package:disperse/animation/color_utilities.dart';
import 'package:disperse/animation/shader_utilities.dart';
import 'package:disperse/recording/recorder.dart';
import 'package:disperse/recording/recording_events.dart';
import 'package:disperse/recording/replay_widget.dart';
import 'package:disperse/util/configuration.dart';
import 'package:disperse/util/user_preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'animation/shapes_utilities.dart';
import 'main_panel.dart';

class TouchListener extends StatefulWidget {
  @override
  _TouchListenerState createState() => _TouchListenerState();
}

class _TouchListenerState extends State<TouchListener>
    with ShapeClickable<TouchListener> {
  AssetImage image;
  Timer generalTimer;

  /// Need to have 2 maps as onTapUp and onDragEnd have different ways of identifying the timers
  Map<Offset, TapDragTimer> posToDrag;
  Map<int, TapDragTimer> indexToDrag;

  @override
  void initState() {
    super.initState();
    widgets = [];
    loadImage();
    generalTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (!mounted) {
        timer.cancel();
      } else {
        loadImage();
      }
    });
    posToDrag = {};
    indexToDrag = {};
  }

  Future loadImage() async {
    int random = BackgroundUtilities.getBackgroundIndex();
    AssetImage img = BackgroundUtilities.getBackground(random);
    Recorder()
        .addBackgroundEvent(BackgroundChangeEvent(DateTime.now(), random));
    return img
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool val) {
      if (mounted) {
        setState(() => image = img);
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return Container();
    }
    Configuration.screenHeight ??= MediaQuery.of(context).size.height;
    Configuration.screenWidth ??= MediaQuery.of(context).size.width;
    return RawGestureDetector(
        behavior: HitTestBehavior.translucent,
        gestures: {
          MultiTapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<MultiTapGestureRecognizer>(
            () => MultiTapGestureRecognizer(debugOwner: this),
            (MultiTapGestureRecognizer instance) {
              instance
                ..onTapDown = (int index, TapDownDetails position) {
                  Offset offset = position.globalPosition;
                  touchOn(offset);
                  TapDragTimer drag =
                      TapDragTimer(offset, (pos) => touchOn(pos), index: index);
                  posToDrag.putIfAbsent(offset, () => drag);
                  indexToDrag.putIfAbsent(index, () => drag);
                }
                ..onTapCancel = (int index) {
                  cancelTimer(index: index);
                }
                ..onTapUp = (int index, TapUpDetails pos) {
                  cancelTimer(index: index);
                };
            },
          ),
          ImmediateMultiDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                      ImmediateMultiDragGestureRecognizer>(
                  () => ImmediateMultiDragGestureRecognizer(debugOwner: this),
                  (ImmediateMultiDragGestureRecognizer instance) {
            instance.onStart = (Offset offset) {
              TapDragTimer drag = posToDrag[offset];
              if (drag == null) {
                drag = TapDragTimer(offset, (pos) => touchOn(pos));
                posToDrag.putIfAbsent(offset, () => drag);
              }
              return _DragHandler(offset, drag, (position) {
                cancelTimer(position: position);
              });
            };
          }),
        },
        child: ShapeDisplayWidget(image, widgets));
  }

  void cancelTimer({int index, Offset position}) {
    TapDragTimer drag;
    if (index != null) {
      drag = indexToDrag.remove(index);
      if (drag == null) {
        return;
      }
      posToDrag.remove(drag.originalPosition);
    } else {
      drag = posToDrag.remove(position);
      if (drag == null) {
        return;
      }
      indexToDrag.remove(drag.index);
    }
    drag.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    generalTimer.cancel();
  }

  void touchOn(Offset offset) {
    PaintingEvent event = PaintingEvent(
        DateTime.now(),
        ShapeCalculator().getNextShape(),
        ColorCalculator().getNextColor(),
        UserPreferencesUtilities.getMaxRadius(),
        offset,
        ShaderUtilities.getMaskIndex());
    Recorder().addPaintingEvent(event);
    click(event);
  }
}

class _DragHandler extends Drag {
  TapDragTimer tapDragTimer;
  Offset position;
  final Offset originalPosition;
  final void Function(Offset) onEnd;

  _DragHandler(this.originalPosition, this.tapDragTimer, this.onEnd) {
    position = originalPosition;
  }

  @override
  void update(DragUpdateDetails details) {
    tapDragTimer.position = details.globalPosition;
  }

  @override
  void end(DragEndDetails details) {
    onEnd(originalPosition);
  }

  @override
  void cancel() {
    onEnd(originalPosition);
  }
}

class TapDragTimer {
  Timer timer;
  Offset position;

  final Offset originalPosition;
  final int index;
  final void Function(Offset offset) onTimer;

  TapDragTimer(this.originalPosition, this.onTimer, {this.index = -1}) {
    timer = Timer.periodic(
        Duration(milliseconds: Configuration.PERIOD_DRAG_DETECTION), (timer) {
      onTimer(position);
    });
    position = originalPosition;
  }

  void cancel() {
    timer.cancel();
  }
}
