
import 'dart:ui' as painting;

import 'package:disperse/util/configuration.dart';
import 'package:flutter/material.dart';

abstract class SharePainter extends CustomPainter {
  static int get gradientEnd => Configuration.GRADIENT_END;

  final double radius;
  Paint painter;
  final Offset center;

  SharePainter(this.radius, this.center, Color color) {
    Color gradientEnd = calcGrad(color);
    painter = Paint()
      ..shader = painting.Gradient.radial(
          center, radius,
          [color, gradientEnd],)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.srcOver
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size);

  @override
  bool shouldRepaint(SharePainter oldDelegate) {
    return oldDelegate.radius != radius;
  }

  painting.Color calcGrad(painting.Color color) {
    return Color.fromARGB(255, color.red - gradientEnd, color.green - gradientEnd, color.blue - gradientEnd);
  }
}
