import 'package:flutter/material.dart';
import 'package:ridingmate/shared/filter/models/filter_config.dart';
import 'package:ridingmate/shared/filter/models/filter_item.dart';

class RecommendedCourseFilterConfig implements FilterConfig {
  @override
  List<FilterItem> get filters => <FilterItem>[
    FilterItem.selection(
      id: 'courseType',
      title: '코스 종류',
      options: const <String>['전체', '국토 종주', '대회 코스', '유명 코스'],
    ),
    FilterItem.selection(
      id: 'region',
      title: '지역',
      options: const <String>[
        '전체',
        '서울 북부',
        '서울 남부',
        '경기 북부',
        '경기 남부',
        '인천',
        '강원',
        '대전',
        '충북',
        '충남',
        '세종',
        '광주',
        '전북',
        '전남',
        '울산',
        '부산',
        '대구',
        '경북',
        '경남',
        '제주',
      ],
    ),
    FilterItem.range(
      id: 'elevation',
      title: '상승 고도',
      range: const RangeValues(0, 500),
      unit: 'm',
    ),
    FilterItem.range(
      id: 'distance',
      title: '거리',
      range: const RangeValues(0, 100),
      unit: 'km',
    ),
    FilterItem.selection(
      id: 'roadType',
      title: '도로',
      options: const <String>['전체', '공도 많음', '비포장도로 포함'],
    ),
    FilterItem.selection(
      id: 'scenery',
      title: '자연 경관',
      options: const <String>['전체', '해안가', '하천', '산', '공원'],
    ),
  ];
}
