import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/services/bbox_service.dart';

class FitMapToRoutesUseCase {
  const FitMapToRoutesUseCase({required BboxService bboxService})
    : _bboxService = bboxService;

  final BboxService _bboxService;

  LatLngBounds execute(
    List<RouteData> routeSegments, {
    double paddingRatio = 0.8,
  }) {
    final List<List<double>?> allBboxes =
        routeSegments.map((RouteData segment) => segment.bbox).toList();

    final List<double> mergedBbox = _bboxService.mergeBboxes(allBboxes);

    final List<double> expandedBbox = _bboxService.expandBbox(
      mergedBbox,
      paddingRatio: paddingRatio,
    );

    return LatLngBounds(
      LatLng(expandedBbox[1], expandedBbox[0]),
      LatLng(expandedBbox[3], expandedBbox[2]),
    );
  }
}
