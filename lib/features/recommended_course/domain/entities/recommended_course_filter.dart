import 'package:urban_breeze/features/recommended_course/domain/constants/recommended_course_constants.dart';
import 'package:urban_breeze/shared/filter/models/base_filter.dart';

class RecommendedCourseFilter extends BaseFilter {
  const RecommendedCourseFilter({
    super.page = 0,
    super.size = RecommendedCourseConstants.defaultPageSize,
    this.sortType = RecommendedCourseConstants.defaultSortType,
    this.regions,
    this.difficulty,
    this.recommendationTypes,
    super.minDistance = RecommendedCourseConstants.defaultMinDistance,
    super.maxDistance = RecommendedCourseConstants.defaultMaxDistance,
    super.minElevation = RecommendedCourseConstants.defaultMinElevation,
    super.maxElevation = RecommendedCourseConstants.defaultMaxElevation,
    this.userLon,
    this.userLat,
  });

  final String sortType; // 정렬 타입
  final List<String>? regions; // 지역 필터
  final List<String>? difficulty; // 난이도 필터
  final List<String>? recommendationTypes; // 추천 타입 필터
  final double? userLon; // 사용자 경도 (가까운 순 정렬용)
  final double? userLat; // 사용자 위도 (가까운 순 정렬용)

  @override
  double getDefaultMaxDistance() =>
      RecommendedCourseConstants.defaultMaxDistance;

  @override
  double getDefaultMaxElevation() =>
      RecommendedCourseConstants.defaultMaxElevation;

  @override
  bool get hasAppliedFilters {
    return hasDistanceFilter ||
        hasElevationFilter ||
        regions != null ||
        difficulty != null ||
        recommendationTypes != null;
  }

  @override
  RecommendedCourseFilter copyWith({
    int? page,
    int? size,
    double? minDistance,
    double? maxDistance,
    double? minElevation,
    double? maxElevation,
    String? sortType,
    List<String>? regions,
    List<String>? difficulty,
    List<String>? recommendationTypes,
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
