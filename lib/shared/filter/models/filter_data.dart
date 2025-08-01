import 'package:flutter/material.dart';

import 'filter_item.dart';
import 'filter_type.dart';

class FilterData {
  // 기본값으로 초기화하는 팩토리 메서드
  factory FilterData.fromFilterItems(List<FilterItem> filters) {
    final Map<String, dynamic> initialValues = <String, dynamic>{};

    for (final FilterItem filter in filters) {
      switch (filter.type) {
        case FilterType.selection:
          if (filter.options != null && filter.options!.isNotEmpty) {
            initialValues[filter.id] = filter.options!.first; // 첫번째 옵션이 기본값
          }
          break;
        case FilterType.range:
          if (filter.range != null) {
            initialValues[filter.id] = filter.range!; // 기본 범위가 기본값
          }
          break;
      }
    }

    return FilterData(
      values: initialValues,
      selectedTab: filters.isNotEmpty ? filters.first.title : '',
    );
  }

  const FilterData({
    this.values = const <String, dynamic>{},
    this.selectedTab = '',
  });

  final Map<String, dynamic> values;
  final String selectedTab;

  FilterData copyWith({Map<String, dynamic>? values, String? selectedTab}) {
    return FilterData(
      values: values ?? this.values,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  String? getStringValue(String key) => values[key] as String?;
  RangeValues? getRangeValue(String key) => values[key] as RangeValues?;

  FilterData setStringValue(String key, String value) {
    final Map<String, dynamic> newValues = Map<String, dynamic>.from(values);
    newValues[key] = value;
    return copyWith(values: newValues);
  }

  FilterData setRangeValue(String key, RangeValues value) {
    final Map<String, dynamic> newValues = Map<String, dynamic>.from(values);
    newValues[key] = value;
    return copyWith(values: newValues);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterData &&
        other.values.toString() == values.toString() &&
        other.selectedTab == selectedTab;
  }

  @override
  int get hashCode {
    return Object.hash(values.toString(), selectedTab);
  }

  @override
  String toString() {
    return 'FilterData(values: $values, selectedTab: $selectedTab)';
  }
}
