import 'package:flutter/material.dart';
import 'package:ridingmate/shared/filter/models/filter_item.dart';

class MyRouteFilterConfig {
  static final List<FilterItem> filters = <FilterItem>[
    FilterItem.selection(
      id: 'creator',
      title: '생성자',
      options: const <String>['전체', '내가 생성한 경로', '공유 받은 경로'],
    ),
    FilterItem.range(
      id: 'elevation',
      title: '상승 고도',
      range: const RangeValues(0, 122),
      unit: 'm',
    ),
    FilterItem.range(
      id: 'distance',
      title: '거리',
      range: const RangeValues(0, 999),
      unit: 'km',
    ),
  ];

  static const List<String> tabs = <String>['생성자', '상승 고도', '거리'];
  static const List<String> courseTypes = <String>[
    '전체',
    '내가 생성한 경로',
    '공유 받은 경로',
  ];
  static const double minElevation = 0;
  static const double maxElevation = 122;
  static const double minDistance = 0;
  static const double maxDistance = 999;
}
