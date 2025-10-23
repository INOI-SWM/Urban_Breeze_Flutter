import 'dart:math' as math;

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
    // 1. 기존 방식으로 geometry 생성
    final List<GeometryPoint> geometry = extractGeometryFromSegments(
      routeSegments,
    );

    // 2. RoutePin을 순회하며 waypoint가 있는 경우 geometry에 매핑
    for (final RoutePin pin in pins) {
      if (pin.hasWaypoint) {
        // 핀 위치와 일치하는 geometry 포인트 찾기
        final int geometryIndex = _findGeometryIndexForPin(
          geometry,
          pin.position,
        );

        if (geometryIndex != -1) {
          // waypoint 정보를 포함한 새로운 GeometryPoint로 교체
          geometry[geometryIndex] = GeometryPoint(
            longitude: geometry[geometryIndex].longitude,
            latitude: geometry[geometryIndex].latitude,
            elevation: geometry[geometryIndex].elevation,
            waypoint: pin.waypoint,
          );
        }
      }
    }

    return geometry;
  }

  /// 핀 위치와 일치하는 geometry 포인트의 인덱스를 찾습니다.
  static int _findGeometryIndexForPin(
    List<GeometryPoint> geometry,
    LatLng pinPosition,
  ) {
    // 1. 정확한 위치 매칭 시도 (소수점 4자리 정확도)
    for (int i = 0; i < geometry.length; i++) {
      final GeometryPoint point = geometry[i];
      if ((point.latitude - pinPosition.latitude).abs() < 0.0001 &&
          (point.longitude - pinPosition.longitude).abs() < 0.0001) {
        return i;
      }
    }

    // 2. 가장 가까운 포인트 찾기 (fallback)
    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < geometry.length; i++) {
      final GeometryPoint point = geometry[i];
      final double distance = _calculateDistance(
        pinPosition.latitude,
        pinPosition.longitude,
        point.latitude,
        point.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  /// 두 좌표 간의 거리를 계산합니다 (Haversine 공식, 미터 단위).
  static double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371000; // 지구 반지름 (미터)
    final double dLat = (lat2 - lat1) * (math.pi / 180);
    final double dLng = (lng2 - lng1) * (math.pi / 180);
    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final double c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }
}
