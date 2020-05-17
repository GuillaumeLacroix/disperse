import 'package:disperse/animation/shapes_utilities.dart';
import 'package:flutter/material.dart';
import 'package:disperse/animation/animator.dart';
import 'package:disperse/shapes/shape_painter.dart';

class SquareAnimator extends Animator {
  SquareAnimator(Offset offset, Function(Widget) listener, Color color,
      double maxRadius, int maskIndex,
      {Key key})
      : super(key, offset, listener, Shape.SQUARE, color, maxRadius, maskIndex);

  @override
  CustomPainter createWidget(double radius, Color color) {
    return SquarePainter(radius, offset, color);
  }
}

class SquarePainter extends SharePainter {
  SquarePainter(double radius, Offset center, Color color)
      : super(radius, center, color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromCenter(center: center, width: radius, height: radius),
        painter);
  }
}
