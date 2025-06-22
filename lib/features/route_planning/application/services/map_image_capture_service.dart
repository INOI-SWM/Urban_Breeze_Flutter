import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MapImageCaptureService {
  static Future<Uint8List?> captureMapImage(
    GlobalKey mapKey, {
    double pixelRatio = 3.0,
  }) async {
    try {
      final RenderRepaintBoundary? boundary =
          mapKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        return null;
      }

      if (boundary.debugNeedsPaint) {
        return null;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        return null;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      return pngBytes;
    } catch (e) {
      return null;
    }
  }
}
