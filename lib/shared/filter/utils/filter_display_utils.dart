import 'package:flutter/material.dart';

import '../models/filter_data.dart';
import '../models/filter_item.dart';
import '../models/filter_type.dart';

/// 필터 표시를 위한 데이터 변환 및 포맷팅 유틸리티 클래스
class FilterDisplayUtils {
  /// 선택된 카테고리들을 반환
  static Set<String> getSelectedCategories(
    FilterData data,
    List<FilterItem> filters,
    String? sortOption,
  ) {
    final Set<String> selectedCategories = <String>{};

    // 정렬 옵션이 기본값이 아니면 추가
    if (sortOption != null) {
      selectedCategories.add(sortOption);
    }

    // 필터 설정에 따라 선택된 카테고리 추가
    for (final FilterItem filter in filters) {
      switch (filter.type) {
        case FilterType.selection:
          final String? value = data.getStringValue(filter.id);
          if (value != null && value != filter.options?.first) {
            selectedCategories.add(
              getCategoryText(data, filters, filter.title),
            );
          }
          break;
        case FilterType.range:
          final RangeValues? value = data.getRangeValue(filter.id);
          final RangeValues defaultRange =
              filter.range ?? const RangeValues(0, 100);
          if (value != null &&
              (value.start != defaultRange.start ||
                  value.end != defaultRange.end)) {
            selectedCategories.add(
              getCategoryText(data, filters, filter.title),
            );
          }
          break;
      }
    }

    return selectedCategories;
  }

  /// 카테고리별 표시 텍스트를 반환
  static String getCategoryText(
    FilterData data,
    List<FilterItem> filters,
    String category,
  ) {
    // 필터 설정에서 해당 카테고리 찾기
    final FilterItem? filter =
        filters.where((FilterItem f) => f.title == category).firstOrNull;

    if (filter == null) return category;

    switch (filter.type) {
      case FilterType.selection:
        final String? value = data.getStringValue(filter.id);
        if (value == null || value == filter.options?.first) {
          return filter.title; // 기본값이면 제목 반환
        }
        return value; // 선택된 값 반환
      case FilterType.range:
        final RangeValues? value = data.getRangeValue(filter.id);
        final RangeValues defaultRange =
            filter.range ?? const RangeValues(0, 100);
        if (value == null ||
            (value.start == defaultRange.start &&
                value.end == defaultRange.end)) {
          return filter.title; // 기본값이면 제목 반환
        }
        return '${value.start.round()} ~ ${value.end.round()} ${filter.unit}'; // 범위 값 반환
    }
  }

  /// 적용된 필터 개수를 반환
  static int getAppliedFiltersCount(FilterData data, List<FilterItem> filters) {
    int count = 0;

    // 필터 설정에 따라 적용된 필터 개수 계산
    for (final FilterItem filter in filters) {
      switch (filter.type) {
        case FilterType.selection:
          final String? value = data.getStringValue(filter.id);
          if (value != null && value != filter.options?.first) {
            count++;
          }
          break;
        case FilterType.range:
          final RangeValues? value = data.getRangeValue(filter.id);
          final RangeValues defaultRange =
              filter.range ?? const RangeValues(0, 100);
          if (value != null &&
              (value.start != defaultRange.start ||
                  value.end != defaultRange.end)) {
            count++;
          }
          break;
      }
    }

    return count;
  }

  /// 표시할 카테고리 리스트를 반환
  static List<String> getDisplayCategories(
    FilterData data,
    List<FilterItem> filters,
    String sortOption,
  ) {
    return <String>[
      sortOption,
      ...filters.map(
        (FilterItem filter) => getCategoryText(data, filters, filter.title),
      ),
    ];
  }
}
