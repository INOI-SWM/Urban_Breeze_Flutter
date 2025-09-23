import 'package:flutter/material.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_filter.dart';
import 'package:urban_breeze/features/my_route/domain/enums/my_route_sort_type.dart';
import 'package:urban_breeze/shared/filter/models/filter_data.dart';
import 'package:urban_breeze/shared/filter/utils/filter_converter.dart';

/// Presentation layer에서 UI 필터를 Domain 필터로 변환하는 매퍼
/// 클린아키텍처를 위해 Domain이 shared 모델에 의존하지 않도록 분리
class MyRouteFilterMapper {
  /// UI FilterData를 Domain MyRouteFilter로 변환
  static MyRouteFilter fromFilterData(
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
}
