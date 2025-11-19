import 'package:urban_breeze/features/route_planning/domain/entities/waypoint.dart';
import 'package:urban_breeze/shared/utils/display_formatter.dart';

class MyRouteDetail {
  const MyRouteDetail({
    required this.routeId,
    required this.title,
    required this.polyline,
    required this.createdAt,
    required this.durationSeconds,
    required this.distance,
    required this.elevationGain,
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
    required this.trackPointsCount,
    required this.trackPoints,
    required this.bbox,
  });

  final String routeId;
  final String title;
  final String polyline;
  final DateTime createdAt;
  final int durationSeconds; // 초 단위
  final double distance; // m 단위 (API에서 미터로 받음)
  final double elevationGain;
  final String userId;
  final String nickname;
  final String profileImageUrl;
  final int trackPointsCount;
  final List<TrackPoint> trackPoints;
  final List<double> bbox; // [minLng, minLat, maxLng, maxLat]

  /// 거리 표시용 문자열 반환 (미터 → km)
  String get distanceDisplay =>
      DisplayFormatter.formatDistanceFromMeters(distance);
}

class TrackPoint {
  const TrackPoint({
    required this.index,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    this.waypoint,
  });

  final int index;
  final double latitude;
  final double longitude;
  final double elevation;
  final Waypoint? waypoint;
}
