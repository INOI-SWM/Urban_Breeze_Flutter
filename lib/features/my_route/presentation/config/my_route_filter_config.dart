import 'package:flutter/material.dart';
import 'package:urban_breeze/shared/filter/models/filter_config.dart';
import 'package:urban_breeze/shared/filter/models/filter_item.dart';

class MyRouteFilterConfig implements FilterConfig {
  @override
  List<FilterItem> get filters => <FilterItem>[
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
}
