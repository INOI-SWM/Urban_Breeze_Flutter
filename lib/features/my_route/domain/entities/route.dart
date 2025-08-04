class Route {
  const Route({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.distance,
    required this.elevationGain,
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
  });

  final int id;
  final String title;
  final String thumbnailUrl;
  final DateTime createdAt;
  final double distance;
  final double elevationGain;
  final int userId;
  final String nickname;
  final String profileImageUrl;

  /// 생성일 표시용 문자열 반환 (YYYY-MM-DD 형식)
  String get createdAtDisplay =>
      '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Route && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Route(id: $id, title: $title, distance: $distance, elevationGain: $elevationGain)';
  }
}
