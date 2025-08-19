class RecommendedCourseFilter {
  const RecommendedCourseFilter({
    this.page = 0,
    this.size = 10, // API 기본값: 10개
    this.sortType = 'NEAREST', // API 기본값: 가까운 순
    this.regions,
    this.difficulty,
    this.recommendationTypes,
    this.minDistance = 0.0,
    this.maxDistance = 100.0,
    this.minElevation = 0.0,
    this.maxElevation = 1000.0,
    this.userLon,
    this.userLat,
  });

  final int page;
  final int size;
  final String sortType; // 정렬 타입
  final List<String>? regions; // 지역 필터
  final List<String>? difficulty; // 난이도 필터
  final List<String>? recommendationTypes; // 추천 타입 필터
  final double minDistance; // 최소 거리 (km)
  final double maxDistance; // 최대 거리 (km)
  final double minElevation; // 최소 상승 고도 (m)
  final double maxElevation; // 최대 상승 고도 (m)
  final double? userLon; // 사용자 경도 (가까운 순 정렬용)
  final double? userLat; // 사용자 위도 (가까운 순 정렬용)

  RecommendedCourseFilter copyWith({
    int? page,
    int? size,
    String? sortType,
    List<String>? regions,
    List<String>? difficulty,
    List<String>? recommendationTypes,
    double? minDistance,
    double? maxDistance,
    double? minElevation,
    double? maxElevation,
    double? userLon,
    double? userLat,
  }) {
    return RecommendedCourseFilter(
      page: page ?? this.page,
      size: size ?? this.size,
      sortType: sortType ?? this.sortType,
      regions: regions ?? this.regions,
      difficulty: difficulty ?? this.difficulty,
      recommendationTypes: recommendationTypes ?? this.recommendationTypes,
      minDistance: minDistance ?? this.minDistance,
      maxDistance: maxDistance ?? this.maxDistance,
      minElevation: minElevation ?? this.minElevation,
      maxElevation: maxElevation ?? this.maxElevation,
      userLon: userLon ?? this.userLon,
      userLat: userLat ?? this.userLat,
    );
  }
}
