/// 모든 필터의 공통 인터페이스
abstract class BaseFilter {
  const BaseFilter({
    required this.page,
    required this.size,
    this.minDistance,
    this.maxDistance,
    this.minElevation,
    this.maxElevation,
  });

  /// 페이지네이션
  final int page;
  final int size;

  /// 거리 범위 (km) - null이면 필터가 적용되지 않음
  final double? minDistance;
  final double? maxDistance;

  /// 상승 고도 범위 (m) - null이면 필터가 적용되지 않음
  final double? minElevation;
  final double? maxElevation;

  /// 필터가 적용되었는지 확인
  bool get hasAppliedFilters;

  /// 거리 필터가 적용되었는지 확인
  bool get hasDistanceFilter =>
      (minDistance != null && minDistance! > 0) ||
      (maxDistance != null && maxDistance! < getDefaultMaxDistance());

  /// 고도 필터가 적용되었는지 확인
  bool get hasElevationFilter =>
      (minElevation != null && minElevation! > 0) ||
      (maxElevation != null && maxElevation! < getDefaultMaxElevation());

  /// 기본 최대 거리값 (하위 클래스에서 구현)
  double getDefaultMaxDistance();

  /// 기본 최대 고도값 (하위 클래스에서 구현)
  double getDefaultMaxElevation();

  /// 필터 업데이트 (하위 클래스에서 구현)
  BaseFilter copyWith({
    int? page,
    int? size,
    double? minDistance,
    double? maxDistance,
    double? minElevation,
    double? maxElevation,
  });
}
