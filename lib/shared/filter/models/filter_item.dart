import 'package:flutter/material.dart';

import 'filter_type.dart';

class FilterItem {
  const FilterItem._({
    required this.id,
    required this.title,
    required this.type,
    required this.options,
    required this.range,
    required this.unit,
  });

  // 선택형 필터 생성자
  factory FilterItem.selection({
    required String id,
    required String title,
    required List<String> options,
  }) {
    return FilterItem._(
      id: id,
      title: title,
      type: FilterType.selection,
      options: options,
      range: null,
      unit: null,
    );
  }

  // 범위형 필터 생성자
  factory FilterItem.range({
    required String id,
    required String title,
    required RangeValues range,
    required String unit,
  }) {
    return FilterItem._(
      id: id,
      title: title,
      type: FilterType.range,
      options: null,
      range: range,
      unit: unit,
    );
  }

  final String id;
  final String title;
  final FilterType type;
  final List<String>? options; // selection 타입용
  final RangeValues? range; // range 타입용
  final String? unit; // range 타입용

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterItem &&
        other.id == id &&
        other.title == title &&
        other.type == type &&
        other.options == options &&
        other.range == range &&
        other.unit == unit;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, type, options, range, unit);
  }

  @override
  String toString() {
    return 'FilterItem(id: $id, title: $title, type: $type, options: $options, range: $range, unit: $unit)';
  }
}
