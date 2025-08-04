import 'package:flutter/material.dart';
import 'package:ridingmate/features/my_route/data/models/route_filter_model.dart';
import 'package:ridingmate/features/my_route/domain/enums/route_sort_type.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';

class FilterConverter {
  /// UI의 필터 데이터를 API 필터 모델로 변환
  static RouteFilterModel convertFilterToApiFilter(
    FilterData currentFilter,
    RouteSortType selectedSortType,
  ) {
    // 정렬 타입 변환
    ApiRouteSortType apiSortType;
    switch (selectedSortType) {
      case RouteSortType.newest:
        apiSortType = ApiRouteSortType.createdAtDesc;
        break;
      case RouteSortType.oldest:
        apiSortType = ApiRouteSortType.createdAtAsc;
        break;
      case RouteSortType.distanceLong:
        apiSortType = ApiRouteSortType.distanceDesc;
        break;
      case RouteSortType.distanceShort:
        apiSortType = ApiRouteSortType.distanceAsc;
        break;
      case RouteSortType.nearest:
        apiSortType = ApiRouteSortType.createdAtDesc; // 기본값
        break;
    }

    // 필터 값 추출
    double minDistance = 0;
    double maxDistance = 100;
    double minElevation = 0;
    double maxElevation = 100;
    String relationTypes = '';

    // 거리 필터
    if (currentFilter.values.containsKey('distance')) {
      final dynamic distanceValue = currentFilter.values['distance'];
      if (distanceValue is RangeValues) {
        minDistance = distanceValue.start.toDouble();
        maxDistance = distanceValue.end.toDouble();
      }
    }

    // 상승 고도 필터
    if (currentFilter.values.containsKey('elevation')) {
      final dynamic elevationValue = currentFilter.values['elevation'];
      if (elevationValue is RangeValues) {
        minElevation = elevationValue.start.toDouble();
        maxElevation = elevationValue.end.toDouble();
      }
    }

    // 생성자 필터 (relationTypes로 변환)
    if (currentFilter.values.containsKey('creator')) {
      final dynamic creatorValue = currentFilter.values['creator'];
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

    return RouteFilterModel(
      page: 0,
      size: 10,
      sortType: apiSortType,
      relationTypes: relationTypes,
      minDistanceKm: minDistance,
      maxDistanceKm: maxDistance,
      minElevationGain: minElevation,
      maxElevationGain: maxElevation,
    );
  }
}
