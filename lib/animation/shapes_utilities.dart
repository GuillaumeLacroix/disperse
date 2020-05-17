import 'dart:math';

import 'package:disperse/util/configuration.dart';
import 'package:disperse/util/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/default_colors.dart';

enum Shape { CIRCLE, SQUARE, TRIANGLE }

String getShapeStr(Shape shape) {
  switch (shape) {
    case Shape.CIRCLE:
      return 'Circle';
    case Shape.SQUARE:
      return 'Square';
    case Shape.TRIANGLE:
      return 'Triangle';
  }
  return '';
}

class ShapesUtilities {
  static final List<Shape> shapes = [
    Shape.CIRCLE,
    Shape.SQUARE,
    Shape.TRIANGLE
  ];
  static List<Shape> selectedShapes;

  static SharedPreferences get prefs => UserPreferencesUtilities.preferences;

  static Future init() async {
    selectedShapes = [];
    for (int i = 0; i < shapes.length; i++) {
      bool selected =
          prefs.getBool(UserPreferences.SHAPES.toString() + '_$i') ?? true;
      if (selected) {
        selectedShapes.add(shapes[i]);
      }
    }
  }

  static bool isShapeDisplayed(int shapeIndex) {
    return prefs.getBool(UserPreferences.SHAPES.toString() + '_$shapeIndex') ??
        true;
  }

  static Future setShapeDisplayed(int shapeIndex, bool displayed) async {
    if (selectedShapes.length == 1 && !displayed) {
      return;
    }
    return prefs
        .setBool(UserPreferences.SHAPES.toString() + '_$shapeIndex', displayed)
        .then((_) => init());
  }
}

class ShapeWidget extends StatefulWidget {
  final int index;

  const ShapeWidget({Key key, this.index}) : super(key: key);

  @override
  _ShapeWidgetState createState() => _ShapeWidgetState();
}

class _ShapeWidgetState extends State<ShapeWidget> {
  @override
  Widget build(BuildContext context) {
    double size = min(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    size = size / (ShapesUtilities.shapes.length + 1);
    return InkWell(
      customBorder: CircleBorder(),
      onTap: () async {
        await ShapesUtilities.setShapeDisplayed(
            widget.index, !ShapesUtilities.isShapeDisplayed(widget.index));
        setState(() {});
      },
      child: Stack(
        children: <Widget>[
          CustomPaint(
              painter: ShapePainter(widget.index, size),
              child: Container(
                height: size,
                width: size,
              )),
          Padding(
            padding:
                const EdgeInsets.all(Configuration.SETTINGS_STROKE_WIDTH / 2),
            child: SizedBox(
                child: Center(
                    child: Text(
                  getShapeStr(Shape.values[widget.index]),
                      style: Theme.of(context).textTheme.subhead,
                )),
                width: size - Configuration.SETTINGS_STROKE_WIDTH / 2,
                height: size - Configuration.SETTINGS_STROKE_WIDTH / 2),
          )
        ],
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final int index;
  final double length;

  bool isSelected;
  Paint _paint;
  Paint _paintBorder;

  ShapePainter(this.index, this.length) {
    isSelected = ShapesUtilities.isShapeDisplayed(index);
    _paint = Paint()
      ..color = DefaultColors().fillColor
      ..strokeWidth = Configuration.SETTINGS_STROKE_WIDTH
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    _paintBorder = Paint()
      ..strokeWidth = Configuration.SETTINGS_STROKE_WIDTH
      ..color = isSelected
          ? DefaultColors().selectedColor
          : DefaultColors().unselectedColor
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(length / 2, length / 2), length / 2, _paint);
    canvas.drawCircle(Offset(length / 2, length / 2),
        length / 2 - Configuration.SETTINGS_STROKE_WIDTH / 2, _paintBorder);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return isSelected != ShapesUtilities.isShapeDisplayed(index);
  }
}

class ShapeCalculator {
  static final ShapeCalculator _singleton = ShapeCalculator._internal();

  factory ShapeCalculator() {
    return _singleton;
  }

  ShapeCalculator._internal();

  Shape getNextShape() {
    if (ShapesUtilities.selectedShapes == null ||
        ShapesUtilities.selectedShapes.isNotEmpty) {
      int index = Random().nextInt(ShapesUtilities.selectedShapes.length);
      return ShapesUtilities.selectedShapes[index];
    }
    return ShapesUtilities.shapes[0];
  }
}
