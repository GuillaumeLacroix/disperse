import 'dart:math';

import 'package:disperse/animation/shapes_utilities.dart';
import 'package:flutter/material.dart';
import 'package:disperse/animation/animator.dart';
import 'package:disperse/shapes/shape_painter.dart';

class TriangleAnimator extends Animator {
  TriangleAnimator(Offset offset, Function(Widget) listener, Color color,
      double maxRadius, int maskIndex,
      {Key key})
      : super(key, offset, listener, Shape.TRIANGLE, color, maxRadius, maskIndex);

  @override
  CustomPainter createWidget(double radius, Color color) {
    return TrianglePainter(radius, offset, color);
  }
}

class TrianglePainter extends SharePainter {
  TrianglePainter(double radius, Offset center, Color color)
      : super(radius, center, color);

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(center.dx, center.dy + sqrt(3) * radius / 3);
    path.lineTo(center.dx - radius / 2, center.dy - radius * sqrt(3) / 6);
    path.lineTo(center.dx + radius / 2, center.dy - radius * sqrt(3) / 6);
    path.close();
    canvas.drawPath(path, painter);
  }
}
