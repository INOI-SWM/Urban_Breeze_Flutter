class RecommendedCourseDetail {
  const RecommendedCourseDetail({
    required this.routeId,
    required this.title,
    required this.description,
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
    required this.recommendationType,
    required this.landscapeType,
    required this.region,
  });

  final String routeId;
  final String title;
  final String description;
  final String polyline;
  final DateTime createdAt;
  final int durationMinutes;
  final double distance; // km
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
}

class TrackPoint {
  const TrackPoint({required this.index, required this.elevation});

  final int index;
  final double elevation;
}
