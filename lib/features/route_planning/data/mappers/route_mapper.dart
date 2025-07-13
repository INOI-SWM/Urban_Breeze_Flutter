import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/models/route_segment_api_response_model.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_segment.dart';
import 'package:ridingmate/features/route_planning/domain/exceptions/route_domain_exceptions.dart';
import 'package:ridingmate/features/route_planning/domain/services/elevation_calculate_service.dart';

class RouteMapper {
  static const int _elevationIndex = 2;

  static RouteSegment fromDto(RouteApiResponseModel dto) {
    validateRouteData(dto);
    final ({List<LatLng> points, List<double> elevations}) routeData =
        _extractRouteData(dto.geometry);

    final double elevationGain =
        ElevationCalculateService.calculateSmoothedElevationGain(
          routeData.elevations,
        );

    return RouteSegment(
      points: routeData.points,
      elevations: routeData.elevations,
      distance: dto.totalDistance,
      duration: dto.totalDuration,
      elevationGain: elevationGain,
      bbox: dto.bbox,
    );
  }

  static void validateRouteData(RouteApiResponseModel dto) {
    if (dto.geometry.length < 2) {
      throw const RouteValidationException(
        'Route must have at least 2 coordinates',
      );
    }
    if (dto.totalDistance < 0) {
      throw const RouteValidationException('Distance cannot be negative');
    }
    if (dto.totalDuration < 0) {
      throw const RouteValidationException('Duration cannot be negative');
    }
  }

  static ({List<LatLng> points, List<double> elevations}) _extractRouteData(
    List<List<dynamic>> coordinates,
  ) {
    final List<LatLng> points = <LatLng>[];
    final List<double> elevations = <double>[];

    for (final List<dynamic> coord in coordinates) {
      // [longitude, latitude, elevation] → LatLng(latitude, longitude)
      points.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));

      elevations.add(
        coord.length > _elevationIndex
            ? (coord[_elevationIndex] as num).toDouble()
            : 0.0,
      );
    }

    return (points: points, elevations: elevations);
  }
}
