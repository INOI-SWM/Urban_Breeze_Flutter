import 'package:flutter/material.dart';
import 'package:urban_breeze/shared/filter/models/filter_data.dart';

/// Filter 변환을 위한 공통 유틸리티 클래스
class FilterConverter {
  const FilterConverter._();

  /// FilterData에서 거리 범위 추출
  ///
  /// [filterData] UI 필터 데이터
  /// [defaultMin] 기본 최소값
  /// [defaultMax] 기본 최대값
  ///
  /// Returns: (minDistance, maxDistance) 튜플
  static (double, double) extractDistanceRange(
    FilterData filterData, {
    double defaultMin = 0,
    double defaultMax = 100,
  }) {
    final RangeValues? range = filterData.getRangeValue('distance');
    if (range != null) {
      return (range.start, range.end);
    }
    return (defaultMin, defaultMax);
  }

  /// FilterData에서 고도 범위 추출
  ///
  /// [filterData] UI 필터 데이터
  /// [defaultMin] 기본 최소값
  /// [defaultMax] 기본 최대값
  ///
  /// Returns: (minElevation, maxElevation) 튜플
  static (double, double) extractElevationRange(
    FilterData filterData, {
    double defaultMin = 0,
    double defaultMax = 100,
  }) {
    final RangeValues? range = filterData.getRangeValue('elevation');
    if (range != null) {
      return (range.start, range.end);
    }
    return (defaultMin, defaultMax);
  }

  /// FilterData에서 선택된 카테고리들 추출
  ///
  /// [filterData] UI 필터 데이터
  /// [validOptions] 유효한 옵션 목록
  /// [excludeValues] 제외할 값들 (예: '전체')
  ///
  /// Returns: 선택된 카테고리 Set
  static Set<String> extractSelectedCategories(
    FilterData filterData,
    List<String> validOptions, {
    List<String> excludeValues = const <String>['전체'],
  }) {
    final Set<String> selectedCategories = <String>{};

    for (final String key in filterData.values.keys) {
      final dynamic value = filterData.values[key];
      if (value is String &&
          !excludeValues.contains(value) &&
          validOptions.contains(value)) {
        selectedCategories.add(value);
      } else if (value is List<String>) {
        for (final String item in value) {
          if (!excludeValues.contains(item) && validOptions.contains(item)) {
            selectedCategories.add(item);
          }
        }
      }
    }

    return selectedCategories;
  }

  /// 특정 필터 키에서 문자열 값 추출
  ///
  /// [filterData] UI 필터 데이터
  /// [key] 필터 키
  /// [excludeValues] 제외할 값들
  ///
  /// Returns: 추출된 문자열 (없으면 null)
  static String? extractStringValue(
    FilterData filterData,
    String key, {
    List<String> excludeValues = const <String>['전체'],
  }) {
    final String? value = filterData.getStringValue(key);
    if (value != null && !excludeValues.contains(value)) {
      return value;
    }
    return null;
  }

  /// 여러 카테고리에서 특정 타입 추출
  ///
  /// [categories] 전체 카테고리 Set
  /// [validOptions] 해당 타입의 유효한 옵션들
  ///
  /// Returns: 해당 타입에 속하는 카테고리 리스트
  static List<String> extractCategoryType(
    Set<String> categories,
    List<String> validOptions,
  ) {
    return categories
        .where((String category) => validOptions.contains(category))
        .toList();
  }
}
