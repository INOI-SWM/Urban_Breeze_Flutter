import 'package:flutter/material.dart';
import 'package:urban_breeze/features/my_route/domain/enums/my_route_sort_type.dart';
import 'package:urban_breeze/shared/filter/models/base_filter.dart';
import 'package:urban_breeze/shared/filter/models/filter_data.dart';
import 'package:urban_breeze/shared/filter/utils/filter_converter.dart';

class MyRouteFilter extends BaseFilter {
  factory MyRouteFilter.defaultFilter() {
    return const MyRouteFilter();
  }

  /// UI 필터 데이터로부터 생성
  factory MyRouteFilter.fromFilterData(
    FilterData filterData,
    MyRouteSortType sortType,
  ) {
    // FilterConverter를 사용한 범위 값 추출 - null 가능
    double? minDistance;
    double? maxDistance;
    double? minElevation;
    double? maxElevation;

    // distance 범위가 설정되었는지 확인
    final RangeValues? distanceRange = filterData.getRangeValue('distance');
    if (distanceRange != null) {
      minDistance = distanceRange.start;
      maxDistance = distanceRange.end;
    }

    // elevation 범위가 설정되었는지 확인
    final RangeValues? elevationRange = filterData.getRangeValue('elevation');
    if (elevationRange != null) {
      minElevation = elevationRange.start;
      maxElevation = elevationRange.end;
    }

    // 생성자 필터 추출 및 변환
    String relationTypes = '';
    final String? creatorValue = FilterConverter.extractStringValue(
      filterData,
      'creator',
    );
    if (creatorValue != null) {
      switch (creatorValue) {
        case '내가 생성한 경로':
          relationTypes = 'OWNER';
          break;
        case '공유 받은 경로':
          relationTypes = 'SHARED';
          break;
        default:
          relationTypes = '';
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
    super.page = 0,
    super.size = 10,
    this.sortType = MyRouteSortType.newest,
    this.relationTypes = '',
    double? minDistanceKm,
    double? maxDistanceKm,
    double? minElevationGain,
    double? maxElevationGain,
  }) : super(
         minDistance: minDistanceKm,
         maxDistance: maxDistanceKm,
         minElevation: minElevationGain,
         maxElevation: maxElevationGain,
       );

  final MyRouteSortType sortType;
  final String relationTypes;

  // BaseFilter의 값들을 더 명확한 이름으로 접근하기 위한 getter들
  double? get minDistanceKm => minDistance;
  double? get maxDistanceKm => maxDistance;
  double? get minElevationGain => minElevation;
  double? get maxElevationGain => maxElevation;

  @override
  double getDefaultMaxDistance() => 100.0;

  @override
  double getDefaultMaxElevation() => 100.0;

  @override
  bool get hasAppliedFilters {
    return hasDistanceFilter || hasElevationFilter || relationTypes.isNotEmpty;
  }

  @override
  MyRouteFilter copyWith({
    int? page,
    int? size,
    double? minDistance,
    double? maxDistance,
    double? minElevation,
    double? maxElevation,
    MyRouteSortType? sortType,
    String? relationTypes,
  }) {
    return MyRouteFilter(
      page: page ?? this.page,
      size: size ?? this.size,
      sortType: sortType ?? this.sortType,
      relationTypes: relationTypes ?? this.relationTypes,
      minDistanceKm: minDistance ?? minDistanceKm,
      maxDistanceKm: maxDistance ?? maxDistanceKm,
      minElevationGain: minElevation ?? minElevationGain,
      maxElevationGain: maxElevation ?? maxElevationGain,
    );
  }

  /// 기존 호환성을 위한 copyWith 오버로드
  MyRouteFilter copyWithLegacy({
    int? page,
    int? size,
    MyRouteSortType? sortType,
    String? relationTypes,
    double? minDistanceKm,
    double? maxDistanceKm,
    double? minElevationGain,
    double? maxElevationGain,
  }) {
    return copyWith(
      page: page,
      size: size,
      minDistance: minDistanceKm,
      maxDistance: maxDistanceKm,
      minElevation: minElevationGain,
      maxElevation: maxElevationGain,
      sortType: sortType,
      relationTypes: relationTypes,
    );
  }
}
