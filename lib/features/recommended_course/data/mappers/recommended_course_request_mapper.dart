import 'package:urban_breeze/features/recommended_course/data/models/recommended_course_request_model.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_filter.dart';

/// 추천 코스 요청 관련 매핑
/// 도메인 필터와 API 요청 모델 간의 변환을 담당
class RecommendedCourseRequestMapper {
  const RecommendedCourseRequestMapper._();

  /// 도메인 필터를 API 요청 모델로 변환
  static RecommendedCourseRequestModel fromFilter(
    RecommendedCourseFilter filter,
  ) {
    return RecommendedCourseRequestModel(
      page: filter.page,
      size: filter.size,
      sortType: filter.sortType,
      regions: filter.regions,
      difficulties: filter.difficulty,
      recommendationTypes: filter.recommendationTypes,
      minDistanceKm: filter.minDistance,
      maxDistanceKm: filter.maxDistance,
      minElevationGain: filter.minElevation,
      maxElevationGain: filter.maxElevation,
      userLon: filter.userLon,
      userLat: filter.userLat,
    );
  }

  /// API 요청 모델을 도메인 필터로 변환
  static RecommendedCourseFilter toFilter(RecommendedCourseRequestModel model) {
    return RecommendedCourseFilter(
      page: model.page ?? 0,
      size: model.size ?? 10,
      sortType: model.sortType ?? 'NEAREST',
      regions: model.regions,
      difficulty: model.difficulties,
      recommendationTypes: model.recommendationTypes,
      minDistance: model.minDistanceKm,
      maxDistance: model.maxDistanceKm,
      minElevation: model.minElevationGain,
      maxElevation: model.maxElevationGain,
      userLon: model.userLon,
      userLat: model.userLat,
    );
  }
}
