import 'package:urban_breeze/features/route_planning/domain/entities/waypoint.dart';

class GeometryPoint {
  const GeometryPoint({
    required this.longitude,
    required this.latitude,
    required this.elevation,
    this.waypoint,
  });

  final double longitude; // 경도
  final double latitude; // 위도
  final double elevation; // 경사도
  final Waypoint? waypoint; // waypoint 정보 (waypoint가 아닌 경우 null)
}
