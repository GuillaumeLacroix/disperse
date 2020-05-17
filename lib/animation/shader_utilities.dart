import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShaderUtilities {
  static const int MASK_NUMBER = 20;
  static const int IMAGES_PER_MASK = 30;

  static List<List<ui.Image>> masks;
  static Random random;

  static Future init(BuildContext context) async {
    masks = [];
    random = Random();
    for (int i = 0; i < MASK_NUMBER; i++) {
      List<ui.Image> mask = [];
      for (int j = 0; j < IMAGES_PER_MASK; j++) {
        AssetBundle bundle = DefaultAssetBundle.of(context);
        ui.Image img = await _loadImage(AssetBundleImageKey(
            name: 'assets/mask/mask_$i' + '_$j.png', bundle: bundle, scale: 1.0));
        mask.add(img);
      }
      masks.add(mask);
    }
  }

  static List<ui.Image> getMask(int index) {
    return masks[index];
  }

  static int getMaskIndex() {
    return random.nextInt(masks.length);
  }

  static Future<ui.Image> _loadImage(AssetBundleImageKey key) async {
    final ByteData data = await key.bundle.load(key.name);
    if (data == null) throw 'Unable to read data';
    var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    // add additional checking for number of frames etc here
    var frame = await codec.getNextFrame();
    return frame.image;
  }
}
