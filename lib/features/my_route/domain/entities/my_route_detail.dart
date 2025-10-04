import 'package:urban_breeze/shared/utils/display_formatter.dart';

class MyRouteDetail {
  const MyRouteDetail({
    required this.routeId,
    required this.title,
    required this.polyline,
    required this.createdAt,
    required this.durationMinutes,
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
  final int durationMinutes;
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
  const TrackPoint({required this.index, required this.elevation});

  final int index;
  final double elevation;
}
