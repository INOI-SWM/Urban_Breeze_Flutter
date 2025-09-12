class MyRouteDetail {
  const MyRouteDetail({
    required this.id,
    required this.title,
    required this.polyline,
    required this.createdAt,
    required this.duration,
    required this.distance,
    required this.elevationGain,
    required this.userId,
    required this.nickname,
    this.profileImageUrl,
    required this.trackPointsCount,
    required this.trackPoints,
  });

  final int id;
  final String title;
  final String polyline;
  final DateTime createdAt;
  final int duration;
  final double distance;
  final double elevationGain;
  final int userId;
  final String nickname;
  final String? profileImageUrl;
  final int trackPointsCount;
  final List<TrackPoint> trackPoints;
}

class TrackPoint {
  const TrackPoint({required this.index, required this.elevation});

  final int index;
  final double elevation;
}
