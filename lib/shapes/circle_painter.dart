import 'package:disperse/animation/shapes_utilities.dart';
import 'package:flutter/material.dart';
import 'package:disperse/animation/animator.dart';
import 'package:disperse/shapes/shape_painter.dart';

class CircleAnimator extends Animator {
  CircleAnimator(Offset offset, Function(Widget) listener, Color color,
      double maxRadius, int maskIndex,
      {Key key})
      : super(key, offset, listener, Shape.CIRCLE, color, maxRadius, maskIndex);

  @override
  CustomPainter createWidget(double radius, Color color) {
    return CircleWavePainter(radius, offset, color);
  }
}

class CircleWavePainter extends SharePainter {
  CircleWavePainter(double radius, Offset center, Color color)
      : super(radius, center, color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(center, radius / 2, painter);
  }
}
