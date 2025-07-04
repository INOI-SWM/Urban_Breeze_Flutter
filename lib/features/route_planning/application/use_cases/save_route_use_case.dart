import 'package:ridingmate/features/route_planning/application/use_cases/route_stats_use_case.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/exceptions/route_domain_exceptions.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_repository.dart';
import 'package:ridingmate/features/route_planning/domain/services/bbox_service.dart';
import 'package:ridingmate/features/route_planning/domain/services/polyline_convert_service.dart';

class SaveRouteUseCase {
  const SaveRouteUseCase({
    required BboxService bboxService,
    required RouteRepository routeRepository,
    required RouteStatsUseCase routeStatsUseCase,
  }) : _bboxService = bboxService,
       _routeRepository = routeRepository,
       _routeStatsUseCase = routeStatsUseCase;

  final BboxService _bboxService;
  final RouteRepository _routeRepository;
  final RouteStatsUseCase _routeStatsUseCase;

  Future<void> execute(List<RouteData> routeSegments, String title) async {
    try {
      final String encodedPolyline = PolylineConvertService.encodeRouteSegments(
        routeSegments,
      );

      final List<List<double>> allBboxes =
          routeSegments.map((RouteData segment) => segment.bbox).toList();

      final List<double> mergedBbox = _bboxService.mergeBboxes(allBboxes);
      final double totalDistance = _routeStatsUseCase.getTotalDistance(
        routeSegments,
      );
      final int totalDuration = _routeStatsUseCase.getTotalDuration(
        routeSegments,
      );
      final double elevationGain = _routeStatsUseCase.getTotalElevationGain(
        routeSegments,
      );

      final List<double> elevations =
          routeSegments.expand((RouteData seg) => seg.elevations).toList();

      _routeRepository.saveRoute(
        title: title,
        encodedPolyline: encodedPolyline,
        bbox: mergedBbox,
        distance: totalDistance,
        duration: totalDuration,
        elevationGain: elevationGain,
        elevations: elevations,
      );
    } catch (e) {
      throw RouteSaveException('경로 저장 중 오류가 발생했습니다: $e');
    }
  }
}
