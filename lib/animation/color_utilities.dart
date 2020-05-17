import 'dart:math';

import 'package:disperse/util/configuration.dart';
import 'package:disperse/util/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/default_colors.dart';

class ColorUtilities {
  static final List<Color> colors = [theme1, theme2, theme3, theme4, theme5];
  static List<Color> selectedColors;

  static SharedPreferences get prefs => UserPreferencesUtilities.preferences;

  static Color get theme1 => Color(0xFFf68b8f);
  static Color get theme2 => Color(0xFF98dbb4);
  static Color get theme3 => Color(0xFF94e5e2);
  static Color get theme4 => Color(0xFFedb38b);
  static Color get theme5 => Color(0xFFeed68f);

  static Future init() async {
    selectedColors = [];
    for (int i = 0; i < colors.length; i++) {
      bool selected =
          prefs.getBool(UserPreferences.COLOR.toString() + '_$i') ?? true;
      if (selected) {
        selectedColors.add(colors[i]);
      }
    }
  }

  static bool isColorDisplayed(int colorIndex) {
    return prefs.getBool(UserPreferences.COLOR.toString() + '_$colorIndex') ??
        true;
  }

  static Future setColorDisplayed(int colorIndex, bool displayed) async {
    if (selectedColors.length == 1 && !displayed) {
      return;
    }
    return prefs.setBool(
        UserPreferences.COLOR.toString() + '_$colorIndex', displayed).then((_) => init());
  }
}

class ColorWidget extends StatefulWidget {
  final int index;

  const ColorWidget({Key key, this.index}) : super(key: key);

  @override
  _ColorWidgetState createState() => _ColorWidgetState();
}

class _ColorWidgetState extends State<ColorWidget> {
  @override
  Widget build(BuildContext context) {
    double size = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    size = size / (ColorUtilities.colors.length + 1);
    return InkWell(
      onTap: () async {
        await ColorUtilities.setColorDisplayed(widget.index, !ColorUtilities.isColorDisplayed(widget.index));
        setState(() {});
      },
      child: CustomPaint(
        painter: ColorPainter(widget.index, size),
        child: Container(
          height: size,
          width: size,
        ),
      ),
    );
  }
}

class ColorPainter extends CustomPainter {
  final int index;
  final double length;

  bool isSelected;
  Paint _paint;
  Paint _paintBorder;

  ColorPainter(this.index, this.length) {
    isSelected = ColorUtilities.isColorDisplayed(index);
    _paint = Paint()
      ..strokeWidth = Configuration.SETTINGS_STROKE_WIDTH
      ..color = ColorUtilities.colors[index]
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    _paintBorder = Paint()
      ..strokeWidth = Configuration.SETTINGS_STROKE_WIDTH
      ..color = isSelected ? DefaultColors().selectedColor : DefaultColors().unselectedColor
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromCircle(center: Offset(length / 2, length / 2), radius: length / 2), _paint);
    canvas.drawRect(Rect.fromCircle(center: Offset(length / 2, length / 2), radius: length / 2 -
        Configuration.SETTINGS_STROKE_WIDTH / 2), _paintBorder);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return isSelected != ColorUtilities.isColorDisplayed(index);
  }
}

class ColorCalculator {

  static final ColorCalculator _singleton =
  ColorCalculator._internal();

  factory ColorCalculator() {
    return _singleton;
  }

  ColorCalculator._internal();

  Color getNextColor() {
    if (ColorUtilities.selectedColors == null || ColorUtilities.selectedColors.isNotEmpty) {
      int index = Random().nextInt(ColorUtilities.selectedColors.length);
      return ColorUtilities.selectedColors[index];
    }
    return ColorUtilities.colors[0];
  }
}
