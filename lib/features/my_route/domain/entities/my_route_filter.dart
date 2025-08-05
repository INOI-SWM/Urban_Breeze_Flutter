import 'package:flutter/material.dart';
import 'package:ridingmate/features/my_route/domain/enums/my_route_sort_type.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';

class MyRouteFilter {
  factory MyRouteFilter.defaultFilter() {
    return const MyRouteFilter();
  }

  /// UI 필터 데이터로부터 생성
  factory MyRouteFilter.fromFilterData(
    FilterData filterData,
    MyRouteSortType sortType,
  ) {
    // 필터 값 추출
    double minDistance = 0;
    double maxDistance = 100;
    double minElevation = 0;
    double maxElevation = 100;
    String relationTypes = '';

    // 거리 필터
    if (filterData.values.containsKey('distance')) {
      final dynamic distanceValue = filterData.values['distance'];
      if (distanceValue is RangeValues) {
        minDistance = distanceValue.start.toDouble();
        maxDistance = distanceValue.end.toDouble();
      }
    }

    // 상승 고도 필터
    if (filterData.values.containsKey('elevation')) {
      final dynamic elevationValue = filterData.values['elevation'];
      if (elevationValue is RangeValues) {
        minElevation = elevationValue.start.toDouble();
        maxElevation = elevationValue.end.toDouble();
      }
    }

    // 생성자 필터 (relationTypes로 변환)
    if (filterData.values.containsKey('creator')) {
      final dynamic creatorValue = filterData.values['creator'];
      if (creatorValue is String) {
        switch (creatorValue) {
          case '내가 생성한 경로':
            relationTypes = 'CREATED';
            break;
          case '공유 받은 경로':
            relationTypes = 'SHARED';
            break;
          default:
            relationTypes = '';
        }
      }
    }

    return MyRouteFilter(
      sortType: sortType,
      relationTypes: relationTypes,
      minDistanceKm: minDistance,
      maxDistanceKm: maxDistance,
      minElevationGain: minElevation,
      maxElevationGain: maxElevation,
    );
  }

  const MyRouteFilter({
    this.page = 0,
    this.size = 10,
    this.sortType = MyRouteSortType.newest,
    this.relationTypes = '',
    this.minDistanceKm = 0,
    this.maxDistanceKm = 100,
    this.minElevationGain = 0,
    this.maxElevationGain = 100,
  });

  final int page;
  final int size;
  final MyRouteSortType sortType;
  final String relationTypes;
  final double minDistanceKm;
  final double maxDistanceKm;
  final double minElevationGain;
  final double maxElevationGain;

  /// 필터 업데이트
  MyRouteFilter copyWith({
    int? page,
    int? size,
    MyRouteSortType? sortType,
    String? relationTypes,
    double? minDistanceKm,
    double? maxDistanceKm,
    double? minElevationGain,
    double? maxElevationGain,
  }) {
    return MyRouteFilter(
      page: page ?? this.page,
      size: size ?? this.size,
      sortType: sortType ?? this.sortType,
      relationTypes: relationTypes ?? this.relationTypes,
      minDistanceKm: minDistanceKm ?? this.minDistanceKm,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      minElevationGain: minElevationGain ?? this.minElevationGain,
      maxElevationGain: maxElevationGain ?? this.maxElevationGain,
    );
  }

  /// 필터가 적용되었는지 확인
  bool get hasAppliedFilters {
    return minDistanceKm > 0 ||
        maxDistanceKm < 100 ||
        minElevationGain > 0 ||
        maxElevationGain < 100 ||
        relationTypes.isNotEmpty;
  }
}
