import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ridingmate/features/route_planning/application/services/map_image_capture_service.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/services/polyline_convert_service.dart';

class SaveRouteUseCase {
  Future<void> execute(
    List<RouteData> routeSegments,
    String title, {
    GlobalKey? mapKey,
  }) async {
    try {
      final String encodedPolyline = PolylineConvertService.encodeRouteSegments(
        routeSegments,
      );

      Uint8List? thumbnailBytes;
      if (mapKey != null) {
        thumbnailBytes = await MapImageCaptureService.captureMapImage(mapKey);
      }

      // todo: 인코딩된 Polyline과 썸네일 이미지를 서버에 전송하여 저장
      debugPrint('저장할 경로 제목: $title');
      debugPrint('인코딩된 Polyline: $encodedPolyline');
      debugPrint('썸네일 포함 여부: ${thumbnailBytes != null}');
    } catch (e) {
      throw Exception(e);
    }
  }
}
