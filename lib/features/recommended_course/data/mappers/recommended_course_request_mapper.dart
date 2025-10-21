import 'package:flutter/material.dart';
import 'package:urban_breeze/features/recommended_course/data/models/recommended_course_request_model.dart';
import 'package:urban_breeze/features/recommended_course/domain/constants/recommended_course_constants.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_filter.dart';
import 'package:urban_breeze/features/recommended_course/domain/enums/recommended_course_sort_type.dart';
import 'package:urban_breeze/shared/filter/models/filter_data.dart';

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
      minDistanceM: filter.minDistance,
      maxDistanceM: filter.maxDistance,
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
      minDistance: model.minDistanceM,
      maxDistance: model.maxDistanceM,
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

  /// UI FilterData를 Domain RecommendedCourseFilter로 변환
  static RecommendedCourseFilter fromFilterData(
    FilterData filterData,
    RecommendedCourseSortType sortType,
  ) {
    // 범위 값 추출 (RangeValues에서 직접 추출)
    final RangeValues? distanceRange = filterData.getRangeValue('distance');
    final RangeValues? elevationRange = filterData.getRangeValue('elevation');

    // 카테고리 필터 추출 (API 코드로 직접 변환)
    final List<String>? regions = _extractSelectedRegions(filterData);
    final List<String>? difficulties = _extractSelectedDifficulties(filterData);
    final List<String>? recommendationTypes =
        _extractSelectedRecommendationTypes(filterData);

    return RecommendedCourseFilter(
      page: 0, // 필터 변경 시 첫 페이지부터
      sortType: sortType,
      regions: regions,
      difficulty: difficulties,
      recommendationTypes: recommendationTypes,
      minDistance: distanceRange?.start,
      maxDistance: distanceRange?.end,
      minElevation: elevationRange?.start,
      maxElevation: elevationRange?.end,
    );
  }

  /// 지역 필터 추출
  static List<String>? _extractSelectedRegions(FilterData filterData) {
    final String? regionValue = filterData.getStringValue('region');
    if (regionValue != null && regionValue != '전체') {
      // 한글 지역명을 API 코드로 변환
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
    final String? difficultyValue = filterData.getStringValue('difficulty');
    if (difficultyValue != null && difficultyValue != '전체') {
      // 한글 난이도를 API 코드로 변환
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
    final String? typeValue = filterData.getStringValue('recommendationType');
    if (typeValue != null && typeValue != '전체') {
      // 한글 추천타입을 API 코드로 변환
      final String? apiCode =
          RecommendedCourseConstants.recommendationTypeToApiMapping[typeValue];
      if (apiCode != null) {
        return <String>[apiCode];
      }
    }
    return null;
  }
}
