import 'package:disperse/animation/shader_utilities.dart';
import 'package:disperse/animation/shapes_utilities.dart';
import 'package:disperse/util/configuration.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;

abstract class Animator extends StatefulWidget {
  final Offset offset;
  final Function(Widget) listener;
  final Shape shape;
  final Color color;
  final double maxRadius;
  final int maskIndex;

  Animator(Key key, this.offset, this.listener, this.shape, this.color,
      this.maxRadius, this.maskIndex)
      : super(key: key);

  @override
  _AnimatorState createState() =>
      _AnimatorState(color: color, maxRadius: maxRadius, maskIndex: maskIndex);

  CustomPainter createWidget(double radius, Color color);
}

class _AnimatorState extends State<Animator>
    with TickerProviderStateMixin<Animator>, AnimatorMixin<Animator> {
  Color color;

  _AnimatorState({this.color, double maxRadius, int maskIndex}) {
    this.maxRadius = maxRadius;
    this.maskIndex = maskIndex;
  }

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  CustomPainter createWidget() {
    return widget.createWidget(radius, color);
  }

  @override
  void onFinish() {
    widget.listener(widget);
  }
}

mixin AnimatorMixin<T extends StatefulWidget> on TickerProviderStateMixin<T> {
  double radius = 0.0;
  double maxRadius;
  double fade = 0;
  Animation<double> _animation;
  AnimationController controller;
  AnimationController fadeController;
  int maskIndex;
  List<ui.Image> masks;

  @override
  void initState() {
    super.initState();
    masks = ShaderUtilities.getMask(maskIndex);
    controller = AnimationController(
        duration: Duration(milliseconds: Configuration.ENLARGE_ANIMATION_TIME),
        vsync: this);

    fadeController = AnimationController(
        duration: Duration(milliseconds: Configuration.DISPERSE_ANIMATION_TIME),
        vsync: this);

    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        fadeController.forward();
        controller.dispose();
        controller = null;
      }
    });

    fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        fadeController.dispose();
        fadeController = null;
        onFinish();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (fadeController.isAnimating) {
      _animation = Tween(begin: 0.0, end: 1.0).animate(fadeController)
        ..addListener(() {
          setState(() {
            fade = _animation.value;
          });
        });
    } else {
      _animation = Tween(begin: 0.0, end: maxRadius).animate(controller)
        ..addListener(() {
          setState(() {
            radius = _animation.value;
          });
        });
    }

    Widget shape = CustomPaint(
      size: Size(double.infinity, double.infinity),
      painter: createWidget(),
    );
    return fade != 0
        ? ShaderMask(
            child: shape,
            shaderCallback: (Rect bounds) {
              return ImageShader(masks[(fade * 29.99).floor()], TileMode.mirror,
                  TileMode.mirror, Matrix4.identity().storage);
            },
            blendMode: BlendMode.dstOut,
          )
        : shape;
  }

  @override
  void dispose() {
    controller?.dispose();
    fadeController?.dispose();
    super.dispose();
  }

  CustomPainter createWidget();

  void onFinish();
}
