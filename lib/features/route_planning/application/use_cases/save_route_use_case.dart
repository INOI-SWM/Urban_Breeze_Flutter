import 'package:urban_breeze/features/route_planning/domain/entities/geometry_point.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/planned_route.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_segment.dart';
import 'package:urban_breeze/features/route_planning/domain/exceptions/route_domain_exceptions.dart';
import 'package:urban_breeze/features/route_planning/domain/repositories/route_repository.dart';
import 'package:urban_breeze/features/route_planning/domain/services/bbox_service.dart';
import 'package:urban_breeze/features/route_planning/domain/services/polyline_convert_service.dart';

class SaveRouteUseCase {
  const SaveRouteUseCase({
    required BboxService bboxService,
    required RouteRepository routeRepository,
  }) : _bboxService = bboxService,
       _routeRepository = routeRepository;

  final BboxService _bboxService;
  final RouteRepository _routeRepository;

  Future<void> execute(PlannedRoute route) async {
    try {
      final String encodedPolyline = PolylineConvertService.encodeRouteSegments(
        route.segments,
      );

      final List<List<double>> allBboxes =
          route.segments.map((RouteSegment segment) => segment.bbox).toList();

      final List<double> mergedBbox = _bboxService.mergeBboxes(allBboxes);

      final List<GeometryPoint> geometry =
          PolylineConvertService.extractGeometryFromSegmentsWithWaypoints(
            route.segments,
            route.pins,
          );

      await _routeRepository.saveRoute(
        title: route.title ?? '',
        encodedPolyline: encodedPolyline,
        bbox: mergedBbox,
        distance: route.totalDistance,
        duration: route.totalDuration,
        elevationGain: route.totalElevationGain,
        geometry: geometry,
      );
    } catch (e) {
      throw RouteSaveException('경로 저장 중 오류가 발생했습니다: $e');
    }
  }
}
