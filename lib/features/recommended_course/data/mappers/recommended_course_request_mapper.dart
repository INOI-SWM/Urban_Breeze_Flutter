import 'package:urban_breeze/features/recommended_course/data/mappers/recommended_course_field_converter.dart';
import 'package:urban_breeze/features/recommended_course/data/models/recommended_course_request_model.dart';
import 'package:urban_breeze/features/recommended_course/domain/constants/recommended_course_constants.dart';
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
      regions: RecommendedCourseFieldConverter.convertRegionsToApi(
        filter.regions,
      ),
      difficulty: RecommendedCourseFieldConverter.convertDifficultiestoApi(
        filter.difficulty,
      ),
      recommendationTypes:
          RecommendedCourseFieldConverter.convertRecommendationTypesToApi(
            filter.recommendationTypes,
          ),
      minDistance:
          filter.minDistance ?? RecommendedCourseConstants.defaultMinDistance,
      maxDistance:
          filter.maxDistance ?? RecommendedCourseConstants.defaultMaxDistance,
      minElevation:
          filter.minElevation ?? RecommendedCourseConstants.defaultMinElevation,
      maxElevation:
          filter.maxElevation ?? RecommendedCourseConstants.defaultMaxElevation,
      userLon: filter.userLon,
      userLat: filter.userLat,
    );
  }

  /// API 요청 모델을 도메인 필터로 변환
  static RecommendedCourseFilter toFilter(RecommendedCourseRequestModel model) {
    return RecommendedCourseFilter(
      page: model.page,
      size: model.size,
      sortType: model.sortType,
      regions: RecommendedCourseFieldConverter.convertRegionsFromApi(
        model.regions,
      ),
      difficulty: RecommendedCourseFieldConverter.convertDifficultiesFromApi(
        model.difficulty,
      ),
      recommendationTypes:
          RecommendedCourseFieldConverter.convertRecommendationTypesFromApi(
            model.recommendationTypes,
          ),
      minDistance: model.minDistance,
      maxDistance: model.maxDistance,
      minElevation: model.minElevation,
      maxElevation: model.maxElevation,
      userLon: model.userLon,
      userLat: model.userLat,
    );
  }
}
