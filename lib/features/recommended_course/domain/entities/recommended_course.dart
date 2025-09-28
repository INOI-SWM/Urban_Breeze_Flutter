class RecommendedCourse {
  const RecommendedCourse({
    required this.routeId,
    required this.title,
    required this.description,
    required this.distanceKm,
    required this.durationMinutes,
    required this.elevationGain,
    required this.region,
    required this.difficulty,
    required this.recommendationType,
    required this.thumbnailImagePath,
  });

  final String routeId;
  final String title;
  final String description;
  final double distanceKm; // km
  final int durationMinutes; // 예상 소요 시간 (분)
  final double elevationGain; // 상승 고도 (m)
  final String region; // 지역
  final String difficulty; // 난이도
  final String recommendationType; // 추천 타입
  final String thumbnailImagePath; // 썸네일 이미지 경로

  /// 거리 표시용 문자열 반환 km
  /// 100km 이상: 소수점 없음, 10km 이상: 소수점 한자리, 10km 미만: 소수점 두자리
  String get distanceDisplay {
    if (distanceKm >= 100) {
      return '${distanceKm.toStringAsFixed(0)}km';
    } else if (distanceKm >= 10) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.toStringAsFixed(2)}km';
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

  /// 예상 소요 시간 표시용 문자열 반환 (시간:분 형식)
  String get durationDisplay {
    final int hours = durationMinutes ~/ 60;
    final int minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendedCourse && other.routeId == routeId;
  }

  @override
  int get hashCode => routeId.hashCode;

  @override
  String toString() {
    return 'RecommendedCourse(routeId: $routeId, title: $title, distance: $distanceKm, elevationGain: $elevationGain)';
  }
}
