import 'package:urban_breeze/features/recommended_course/data/models/recommended_course_request_model.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_filter.dart';
import 'package:urban_breeze/features/recommended_course/domain/enums/recommended_course_sort_type.dart';

/// 추천 코스 요청 관련 매핑
/// 도메인 필터와 API 요청 모델 간의 변환을 담당
class RecommendedCourseRequestMapper {
  const RecommendedCourseRequestMapper._();

  /// 도메인 필터를 API 요청 모델로 변환
  static RecommendedCourseRequestModel fromFilter(
    RecommendedCourseFilter filter,
  ) {
    // 정렬 타입 변환
    final ApiRecommendedCourseSortType apiSortType = _convertSortTypeToApi(
      filter.sortType,
    );

    return RecommendedCourseRequestModel(
      page: filter.page,
      size: filter.size,
      sortType: apiSortType.value,
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

  /// Domain 정렬 타입을 API 정렬 타입으로 변환
  static ApiRecommendedCourseSortType _convertSortTypeToApi(
    RecommendedCourseSortType sortType,
  ) {
    switch (sortType) {
      case RecommendedCourseSortType.nearest:
        return ApiRecommendedCourseSortType.nearest;
      case RecommendedCourseSortType.distanceLong:
        return ApiRecommendedCourseSortType.distanceLong;
      case RecommendedCourseSortType.distanceShort:
        return ApiRecommendedCourseSortType.distanceShort;
      case RecommendedCourseSortType.difficultyHigh:
        return ApiRecommendedCourseSortType.difficultyHigh;
      case RecommendedCourseSortType.difficultyLow:
        return ApiRecommendedCourseSortType.difficultyLow;
    }
  }

  /// API 요청 모델을 도메인 필터로 변환
  static RecommendedCourseFilter toFilter(RecommendedCourseRequestModel model) {
    // API 정렬 타입을 Domain 정렬 타입으로 변환
    final RecommendedCourseSortType domainSortType = _convertSortTypeFromApi(
      model.sortType,
    );

    return RecommendedCourseFilter(
      page: model.page ?? 0,
      size: model.size ?? 10,
      sortType: domainSortType,
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

  /// API 정렬 타입을 Domain 정렬 타입으로 변환
  static RecommendedCourseSortType _convertSortTypeFromApi(
    String? apiSortType,
  ) {
    if (apiSortType == null) {
      return RecommendedCourseSortType.nearest;
    }

    switch (apiSortType) {
      case 'NEAREST':
        return RecommendedCourseSortType.nearest;
      case 'DISTANCE_LONG':
        return RecommendedCourseSortType.distanceLong;
      case 'DISTANCE_SHORT':
        return RecommendedCourseSortType.distanceShort;
      case 'DIFFICULTY_HIGH':
        return RecommendedCourseSortType.difficultyHigh;
      case 'DIFFICULTY_LOW':
        return RecommendedCourseSortType.difficultyLow;
      default:
        return RecommendedCourseSortType.nearest;
    }
  }
}
