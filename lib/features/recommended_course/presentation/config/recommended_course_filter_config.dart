import 'package:flutter/material.dart';
import 'package:ridingmate/shared/filter/models/filter_config.dart';
import 'package:ridingmate/shared/filter/models/filter_item.dart';

class RecommendedCourseFilterConfig implements FilterConfig {
  @override
  List<FilterItem> get filters => <FilterItem>[
    FilterItem.selection(
      id: 'recommendationType',
      title: '코스 종류',
      options: const <String>['전체', '국토 종주', '대회 코스', '유명 코스'],
    ),
    FilterItem.selection(
      id: 'region',
      title: '지역',
      options: const <String>['전체', '서울/경기', '강원', '충청', '전라', '경상', '제주'],
    ),
    FilterItem.range(
      id: 'elevation',
      title: '상승 고도',
      range: const RangeValues(0, 1000),
      unit: 'm',
    ),
    FilterItem.range(
      id: 'distance',
      title: '거리',
      range: const RangeValues(0, 100),
      unit: 'km',
    ),
    FilterItem.selection(
      id: 'difficulty',
      title: '난이도',
      options: const <String>['전체', '쉬움', '보통', '어려움'],
    ),
  ];
}
