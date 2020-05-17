import 'dart:math';

import 'package:flutter/material.dart';

class BackgroundUtilities {
  static const int BACKGROUND_NUMBER = 3;

  static List<AssetImage> images;
  static Random random;

  static Future init() async {
    if (images == null || images.isEmpty) {
      images = [];
      random = Random();
      for (int i = 0; i < BACKGROUND_NUMBER; i++) {
        AssetImage img = AssetImage('assets/background/background_$i.png');
        images.add(img);
      }
    }
  }

  static int getBackgroundIndex() {
    return images.isNotEmpty
        ? random.nextInt(images.length)
        : -1;
  }

  static AssetImage getBackground(int index) {
    return index != - 1
        ? images[index]
        : AssetImage('assets/background/background_0.png');
  }
}
