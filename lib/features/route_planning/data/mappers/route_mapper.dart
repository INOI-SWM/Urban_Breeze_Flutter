import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/exceptions/route_exceptions.dart';
import 'package:ridingmate/features/route_planning/data/models/route_api_response_model.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/services/elevation_calculate_service.dart';

class RouteMapper {
  static const int _elevationIndex = 2;

  static RouteData fromDto(RouteApiResponseModel dto) {
    validateRouteData(dto);
    final ({List<LatLng> points, List<double> elevations}) routeData =
        _extractRouteData(dto.coordinates);

    final double elevationGain =
        ElevationCalculateService.calculateSmoothedElevationGain(
          routeData.points,
          routeData.elevations,
        );

    return RouteData(
      points: routeData.points,
      distance: dto.distance,
      duration: dto.duration,
      ascent: dto.rawAscent,
      descent: dto.rawDescent,
      elevationGain: elevationGain,
      bbox: dto.bbox,
    );
  }

  static void validateRouteData(RouteApiResponseModel dto) {
    if (dto.coordinates.length < 2) {
      throw const RouteValidationException(
        'Route must have at least 2 coordinates',
      );
    }
    if (dto.distance < 0) {
      throw const RouteValidationException('Distance cannot be negative');
    }
    if (dto.duration < 0) {
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
