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
  final String userId;
  final String nickname;
  final String profileImageUrl;

  /// 거리 표시용 문자열 반환 km
  /// 100km 이상: 소수점 없음, 10km 이상: 소수점 한자리, 10km 미만: 소수점 두자리
  String get distanceDisplay {
    if (distance >= 100) {
      return '${distance.toStringAsFixed(0)}km';
    } else if (distance >= 10) {
      return '${distance.toStringAsFixed(1)}km';
    } else {
      return '${distance.toStringAsFixed(2)}km';
    }
  }

  /// 상승 고도 표시용 문자열 반환 m
  /// 100m 이상: 소수점 없음, 10m 이상: 소수점 한자리, 10m 미만: 소수점 두자리
  String get elevationGainDisplay {
    if (elevationGain >= 100) {
      return '${elevationGain.toStringAsFixed(0)}m';
    } else if (elevationGain >= 10) {
      return '${elevationGain.toStringAsFixed(1)}m';
    } else {
      return '${elevationGain.toStringAsFixed(2)}m';
    }
  }

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
