import 'package:flutter/material.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/services/polyline_convert_service.dart';

class SaveRouteUseCase {
  Future<void> execute(List<RouteData> routeSegments, String title) async {
    try {
      final String encodedPolyline = PolylineConvertService.encodeRouteSegments(
        routeSegments,
      );

      // todo: 인코딩된 Polyline을 서버에 전송하여 저장 (썸네일은 서버에서 생성)
      debugPrint('저장할 경로 제목: $title');
      debugPrint('인코딩된 Polyline: $encodedPolyline');
    } catch (e) {
      throw Exception(e);
    }
  }
}
