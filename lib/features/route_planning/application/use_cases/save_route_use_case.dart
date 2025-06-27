import 'package:flutter/material.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/services/bbox_service.dart';
import 'package:ridingmate/features/route_planning/domain/services/polyline_convert_service.dart';

class SaveRouteUseCase {
  const SaveRouteUseCase({required BboxService bboxService})
    : _bboxService = bboxService;

  final BboxService _bboxService;

  Future<void> execute(List<RouteData> routeSegments, String title) async {
    try {
      final String encodedPolyline = PolylineConvertService.encodeRouteSegments(
        routeSegments,
      );

      final List<List<double>?> allBboxes =
          routeSegments.map((RouteData segment) => segment.bbox).toList();

      final List<double>? mergedBbox = _bboxService.mergeBboxes(allBboxes);

      List<double>? thumbnailBbox;
      if (mergedBbox != null) {
        thumbnailBbox = _bboxService.expandBbox(
          mergedBbox,
          paddingRatio: 0.2, // 20% 패딩 추가
        );
      }

      // todo: 인코딩된 Polyline과 바운딩 박스를 서버에 전송하여 저장 (썸네일은 서버에서 생성)
      debugPrint('저장할 경로 제목: $title');
      debugPrint('인코딩된 Polyline: $encodedPolyline');
      if (thumbnailBbox != null) {
        debugPrint('썸네일 바운딩 박스: ${_bboxService.bboxToString(thumbnailBbox)}');
        debugPrint(
          'Geoapify 형식: rect:${thumbnailBbox[0]},${thumbnailBbox[1]},${thumbnailBbox[2]},${thumbnailBbox[3]}',
        );
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
