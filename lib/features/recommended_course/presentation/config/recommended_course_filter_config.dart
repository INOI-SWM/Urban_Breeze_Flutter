import 'package:flutter/material.dart';
import 'package:urban_breeze/features/recommended_course/domain/constants/recommended_course_constants.dart';
import 'package:urban_breeze/shared/filter/models/filter_config.dart';
import 'package:urban_breeze/shared/filter/models/filter_data.dart';
import 'package:urban_breeze/shared/filter/models/filter_item.dart';

class RecommendedCourseFilterConfig implements FilterConfig {
  const RecommendedCourseFilterConfig({
    this.maxDistance = 100.0,
    this.minDistance = 0.0,
    this.maxElevationGain = 1000.0,
    this.minElevationGain = 0.0,
  });

  final double maxDistance;
  final double minDistance;
  final double maxElevationGain;
  final double minElevationGain;

  @override
  List<FilterItem> get filters => <FilterItem>[
    FilterItem.selection(
      id: 'recommendationType',
      title: '코스 종류',
      options: RecommendedCourseConstants.recommendationTypeFilterOptions,
    ),
    FilterItem.selection(
      id: 'region',
      title: '지역',
      options: RecommendedCourseConstants.regionFilterOptions,
    ),
    FilterItem.range(
      id: 'elevation',
      title: '상승 고도',
      range: RangeValues(minElevationGain, maxElevationGain),
      unit: 'm',
    ),
    FilterItem.range(
      id: 'distance',
      title: '거리',
      range: RangeValues(minDistance, maxDistance),
      unit: 'km',
    ),
    FilterItem.selection(
      id: 'difficulty',
      title: '난이도',
      options: RecommendedCourseConstants.difficultyFilterOptions,
    ),
  ];

  /// 현재 필터값을 반영한 FilterData를 생성합니다.
  FilterData createFilterDataWithCurrentValues(FilterData? currentFilter) {
    if (currentFilter == null) {
      return FilterData.fromFilterItems(filters);
    }

    final Map<String, dynamic> values = Map<String, dynamic>.from(
      currentFilter.values,
    );

    // 거리 범위가 서버 최대/최소값을 벗어나지 않도록 조정
    final RangeValues? currentDistance = values['distance'] as RangeValues?;
    if (currentDistance != null) {
      final bool isDefaultDistance =
          currentDistance.start.round() == minDistance.round() &&
          currentDistance.end.round() == maxDistance.round();
      if (!isDefaultDistance) {
        values['distance'] = RangeValues(
          currentDistance.start.clamp(minDistance, maxDistance),
          currentDistance.end.clamp(minDistance, maxDistance),
        );
      }
    }

    // 상승고도 범위가 서버 최대/최소값을 벗어나지 않도록 조정
    final RangeValues? currentElevation = values['elevation'] as RangeValues?;
    if (currentElevation != null) {
      final bool isDefaultElevation =
          currentElevation.start.round() == minElevationGain.round() &&
          currentElevation.end.round() == maxElevationGain.round();
      if (!isDefaultElevation) {
        values['elevation'] = RangeValues(
          currentElevation.start.clamp(minElevationGain, maxElevationGain),
          currentElevation.end.clamp(minElevationGain, maxElevationGain),
        );
      }
    }

    return FilterData(values: values, selectedTab: currentFilter.selectedTab);
  }
}
