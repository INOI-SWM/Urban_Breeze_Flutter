import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/geometry_point.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_segment.dart';

class PolylineConvertService {
  static String encodeRouteSegments(List<RouteSegment> routeSegments) {
    final List<List<num>> coordinates = <List<num>>[];
    for (final RouteSegment segment in routeSegments) {
      for (final LatLng point in segment.points) {
        coordinates.add(<double>[point.latitude, point.longitude]);
      }
    }

    return encodePolyline(coordinates);
  }

  static List<LatLng> decodeToPoints(String encodedPolyline) {
    if (encodedPolyline.isEmpty) return <LatLng>[];

    try {
      final List<List<num>> coordinates = decodePolyline(encodedPolyline);
      return coordinates
          .map(
            (List<num> coord) =>
                LatLng(coord[0].toDouble(), coord[1].toDouble()),
          )
          .toList();
    } catch (e) {
      return <LatLng>[];
    }
  }

  static List<GeometryPoint> extractGeometryFromSegments(
    List<RouteSegment> routeSegments,
  ) {
    final List<GeometryPoint> geometry = <GeometryPoint>[];

    for (final RouteSegment segment in routeSegments) {
      for (final List<double> coord in segment.originalGeometry) {
        // [longitude, latitude, elevation] 순서로 변환
        geometry.add(
          GeometryPoint(
            longitude: coord[0],
            latitude: coord[1],
            elevation: coord.length > 2 ? coord[2] : 0.0,
          ),
        );
      }
    }

    return geometry;
  }
}
