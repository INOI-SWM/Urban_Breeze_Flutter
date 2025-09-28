import 'package:urban_breeze/features/recommended_course/domain/constants/recommended_course_constants.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_filter.dart';
import 'package:urban_breeze/features/recommended_course/domain/enums/course_sort_type.dart';
import 'package:urban_breeze/shared/filter/models/filter_data.dart';
import 'package:urban_breeze/shared/filter/utils/filter_converter.dart';

/// Presentation layer에서 UI 필터를 Domain 필터로 변환하는 매퍼
/// 클린아키텍처를 위해 Domain이 shared 모델에 의존하지 않도록 분리
class RecommendedCourseFilterMapper {
  /// UI FilterData를 Domain RecommendedCourseFilter로 변환
  static RecommendedCourseFilter fromFilterData(
    FilterData filterData,
    CourseSortType sortType,
  ) {
    // FilterConverter를 사용한 범위 값 추출
    final (
      double minDistance,
      double maxDistance,
    ) = FilterConverter.extractDistanceRange(
      filterData,
      defaultMin: RecommendedCourseConstants.defaultMinDistance,
      defaultMax: RecommendedCourseConstants.defaultMaxDistance,
    );

    final (
      double minElevation,
      double maxElevation,
    ) = FilterConverter.extractElevationRange(
      filterData,
      defaultMin: RecommendedCourseConstants.defaultMinElevation,
      defaultMax: RecommendedCourseConstants.defaultMaxElevation,
    );

    // 카테고리 필터 추출 (API 코드로 직접 변환)
    final List<String>? regions = _extractSelectedRegions(filterData);
    final List<String>? difficulties = _extractSelectedDifficulties(filterData);
    final List<String>? recommendationTypes =
        _extractSelectedRecommendationTypes(filterData);

    return RecommendedCourseFilter(
      sortType: sortType.apiValue,
      regions: regions,
      difficulty: difficulties,
      recommendationTypes: recommendationTypes,
      minDistance: minDistance,
      maxDistance: maxDistance,
      minElevation: minElevation,
      maxElevation: maxElevation,
    );
  }

  /// 지역 필터 추출
  static List<String>? _extractSelectedRegions(FilterData filterData) {
    final String? regionValue = FilterConverter.extractStringValue(
      filterData,
      'region',
    );
    if (regionValue != null && regionValue != '전체') {
      // 한글 → API 코드 변환
      final String? apiCode =
          RecommendedCourseConstants.regionToApiMapping[regionValue];
      if (apiCode != null) {
        return <String>[apiCode];
      }
    }
    return null;
  }

  /// 난이도 필터 추출
  static List<String>? _extractSelectedDifficulties(FilterData filterData) {
    final String? difficultyValue = FilterConverter.extractStringValue(
      filterData,
      'difficulty',
    );
    if (difficultyValue != null && difficultyValue != '전체') {
      // 한글 → API 코드 변환
      final String? apiCode =
          RecommendedCourseConstants.difficultyToApiMapping[difficultyValue];
      if (apiCode != null) {
        return <String>[apiCode];
      }
    }
    return null;
  }

  /// 추천타입 필터 추출
  static List<String>? _extractSelectedRecommendationTypes(
    FilterData filterData,
  ) {
    final String? typeValue = FilterConverter.extractStringValue(
      filterData,
      'recommendationType',
    );
    if (typeValue != null && typeValue != '전체') {
      // 한글 → API 코드 변환
      final String? apiCode =
          RecommendedCourseConstants.recommendationTypeToApiMapping[typeValue];
      if (apiCode != null) {
        return <String>[apiCode];
      }
    }
    return null;
  }
}
