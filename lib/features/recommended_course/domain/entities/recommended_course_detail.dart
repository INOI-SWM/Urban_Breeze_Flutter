import 'package:urban_breeze/shared/utils/display_formatter.dart';

class RecommendedCourseDetail {
  const RecommendedCourseDetail({
    required this.routeId,
    required this.title,
    required this.description,
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
    required this.recommendationType,
    required this.landscapeType,
    required this.region,
  });

  final String routeId;
  final String title;
  final String description;
  final String polyline;
  final DateTime createdAt;
  final int durationSeconds; // 초 단위
  final double distance; // m 단위 (API에서 미터로 받음)
  final double elevationGain; // m
  final String userId;
  final String nickname;
  final String profileImageUrl;
  final int trackPointsCount;
  final List<TrackPoint> trackPoints;
  final List<double> bbox; // [minLng, minLat, maxLng, maxLat]
  final String recommendationType;
  final String landscapeType;
  final String region;

  /// 거리 표시용 문자열 반환 (미터 → km)
  String get distanceDisplay =>
      DisplayFormatter.formatDistanceFromMeters(distance);
}

class TrackPoint {
  const TrackPoint({required this.index, required this.elevation});

  final int index;
  final double elevation;
}
