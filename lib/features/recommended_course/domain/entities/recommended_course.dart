import 'package:urban_breeze/shared/utils/display_formatter.dart';

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
  final int durationMinutes; // 예상 소요 시간 (초)
  final double elevationGain; // 상승 고도 (m)
  final String region; // 지역
  final String difficulty; // 난이도
  final String recommendationType; // 추천 타입
  final String thumbnailImagePath; // 썸네일 이미지 경로

  /// 거리 표시용 문자열 반환
  String get distanceDisplay => DisplayFormatter.formatDistance(distanceKm);

  /// 상승 고도 표시용 문자열 반환
  String get elevationGainDisplay =>
      DisplayFormatter.formatElevationGain(elevationGain);

  /// 예상 소요 시간 표시용 문자열 반환
  String get durationDisplay =>
      DisplayFormatter.formatDurationFromSeconds(durationMinutes);

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
