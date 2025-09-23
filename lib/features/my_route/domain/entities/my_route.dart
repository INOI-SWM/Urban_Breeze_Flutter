class MyRoute {
  const MyRoute({
    required this.routeId,
    required this.title,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.distance,
    required this.elevationGain,
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
  });

  final String routeId;
  final String title;
  final String thumbnailUrl;
  final DateTime createdAt;
  final double distance;
  final double elevationGain;
  final int userId;
  final String nickname;
  final String profileImageUrl;

  /// 거리 표시용 문자열 반환 km
  String get distanceDisplay => '$distance km';

  /// 상승 고도 표시용 문자열 반환 m
  String get elevationGainDisplay => '$elevationGain m';

  /// 생성일 표시용 문자열 반환 (YYYY-MM-DD 형식)
  String get createdAtDisplay =>
      '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyRoute && other.routeId == routeId;
  }

  @override
  int get hashCode => routeId.hashCode;

  @override
  String toString() {
    return 'MyRoute(id: $routeId, title: $title, distance: $distance, elevationGain: $elevationGain)';
  }
}
