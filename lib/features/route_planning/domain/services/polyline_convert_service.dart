import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/geometry_point.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_pin.dart';
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

  static List<GeometryPoint> extractGeometryFromSegmentsWithWaypoints(
    List<RouteSegment> routeSegments,
    List<RoutePin> pins,
  ) {
    final List<GeometryPoint> geometry = <GeometryPoint>[];

    // PlannedRoute 구조 활용: segments[i]는 pins[i] → pins[i+1] 사이의 경로
    for (
      int segmentIndex = 0;
      segmentIndex < routeSegments.length;
      segmentIndex++
    ) {
      final RouteSegment segment = routeSegments[segmentIndex];
      final RoutePin startPin = pins[segmentIndex];
      final RoutePin endPin = pins[segmentIndex + 1];
      final bool isFirstSegment = segmentIndex == 0;

      // 세그먼트의 geometry를 순회하며 GeometryPoint 생성
      for (
        int coordIndex = 0;
        coordIndex < segment.originalGeometry.length;
        coordIndex++
      ) {
        final List<double> coord = segment.originalGeometry[coordIndex];
        final double longitude = coord[0];
        final double latitude = coord[1];
        final double elevation = coord.length > 2 ? coord[2] : 0.0;
        final bool isFirstCoord = coordIndex == 0;
        final bool isLastCoord =
            coordIndex == segment.originalGeometry.length - 1;

        // 중복 방지: 첫 번째 세그먼트가 아니면 시작점 스킵 (이전 세그먼트의 끝점과 중복)
        if (!isFirstSegment && isFirstCoord) {
          continue;
        }

        // 시작 지점 (첫 번째 좌표)
        if (isFirstCoord && startPin.hasWaypoint) {
          geometry.add(
            GeometryPoint(
              longitude: longitude,
              latitude: latitude,
              elevation: elevation,
              waypoint: startPin.waypoint,
            ),
          );
        }
        // 끝 지점 (마지막 좌표)
        else if (isLastCoord && endPin.hasWaypoint) {
          geometry.add(
            GeometryPoint(
              longitude: longitude,
              latitude: latitude,
              elevation: elevation,
              waypoint: endPin.waypoint,
            ),
          );
        }
        // 일반 포인트
        else {
          geometry.add(
            GeometryPoint(
              longitude: longitude,
              latitude: latitude,
              elevation: elevation,
            ),
          );
        }
      }
    }

    return geometry;
  }
}
