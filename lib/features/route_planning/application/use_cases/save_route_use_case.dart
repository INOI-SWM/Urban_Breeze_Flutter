import 'package:flutter/material.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/services/polyline_convert_service.dart';

class SaveRouteUseCase {
  void execute(List<RouteData> routeSegments, String title) {
    final String encodedPolyline = PolylineConvertService.encodeRouteSegments(
      routeSegments,
    );

    // todo : 인코딩된 Polyline을 서버에 전송하여 저장
    debugPrint('인코딩된 Polyline: $encodedPolyline');
  }
}
