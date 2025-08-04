import 'package:flutter/material.dart';
import 'package:ridingmate/features/my_route/data/models/my_route_filter_model.dart';
import 'package:ridingmate/features/my_route/data/models/my_route_list_data_model.dart';
import 'package:ridingmate/features/my_route/data/models/my_route_model.dart';
import 'package:ridingmate/features/my_route/domain/entities/my_route.dart';
import 'package:ridingmate/features/my_route/domain/entities/my_route_filter.dart';
import 'package:ridingmate/features/my_route/domain/entities/my_route_list.dart';
import 'package:ridingmate/features/my_route/domain/enums/my_route_sort_type.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';

class MyRouteMapper {
  /// MyRouteModel을 MyRoute 엔티티로 변환
  static MyRoute fromModel(MyRouteModel model) {
    return MyRoute(
      id: model.id,
      title: model.title,
      thumbnailUrl: model.thumbnailUrl,
      createdAt: DateTime.parse(model.createdAt),
      distance: model.distance,
      elevationGain: model.elevationGain,
      userId: model.userId,
      nickname: model.nickname,
      profileImageUrl: model.profileImageUrl,
    );
  }

  /// MyRouteFilter를 MyRouteFilterModel로 변환
  static MyRouteFilterModel toFilterModel(MyRouteFilter filter) {
    // 정렬 타입 변환
    ApiRouteSortType apiSortType = ApiRouteSortType.createdAtDesc; // 기본값
    switch (filter.sortType) {
      case MyRouteSortType.newest:
        apiSortType = ApiRouteSortType.createdAtDesc;
        break;
      case MyRouteSortType.oldest:
        apiSortType = ApiRouteSortType.createdAtAsc;
        break;
      case MyRouteSortType.distanceLong:
        apiSortType = ApiRouteSortType.distanceDesc;
        break;
      case MyRouteSortType.distanceShort:
        apiSortType = ApiRouteSortType.distanceAsc;
        break;
      case MyRouteSortType.nearest:
        apiSortType = ApiRouteSortType.createdAtDesc; // 기본값
        break;
    }

    return MyRouteFilterModel(
      page: filter.page,
      size: filter.size,
      sortType: apiSortType,
      relationTypes: filter.relationTypes,
      minDistanceKm: filter.minDistanceKm,
      maxDistanceKm: filter.maxDistanceKm,
      minElevationGain: filter.minElevationGain,
      maxElevationGain: filter.maxElevationGain,
    );
  }

  /// UI의 필터 데이터를 API 필터 모델로 변환
  static MyRouteFilterModel fromFilterData(
    FilterData currentFilter,
    MyRouteSortType selectedSortType,
  ) {
    // 정렬 타입 변환
    ApiRouteSortType apiSortType = ApiRouteSortType.createdAtDesc; // 기본값
    switch (selectedSortType) {
      case MyRouteSortType.newest:
        apiSortType = ApiRouteSortType.createdAtDesc;
        break;
      case MyRouteSortType.oldest:
        apiSortType = ApiRouteSortType.createdAtAsc;
        break;
      case MyRouteSortType.distanceLong:
        apiSortType = ApiRouteSortType.distanceDesc;
        break;
      case MyRouteSortType.distanceShort:
        apiSortType = ApiRouteSortType.distanceAsc;
        break;
      case MyRouteSortType.nearest:
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

    return MyRouteFilterModel(
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

  /// MyRouteFilterModel을 MyRouteFilter로 변환
  static MyRouteFilter fromFilterModel(MyRouteFilterModel model) {
    // 정렬 타입 변환
    MyRouteSortType domainSortType;
    switch (model.sortType) {
      case ApiRouteSortType.createdAtDesc:
        domainSortType = MyRouteSortType.newest;
        break;
      case ApiRouteSortType.createdAtAsc:
        domainSortType = MyRouteSortType.oldest;
        break;
      case ApiRouteSortType.distanceDesc:
        domainSortType = MyRouteSortType.distanceLong;
        break;
      case ApiRouteSortType.distanceAsc:
        domainSortType = MyRouteSortType.distanceShort;
        break;
      case ApiRouteSortType.elevationGainDesc:
      case ApiRouteSortType.elevationGainAsc:
        domainSortType = MyRouteSortType.newest; // 기본값
        break;
    }

    return MyRouteFilter(
      page: model.page,
      size: model.size,
      sortType: domainSortType,
      relationTypes: model.relationTypes,
      minDistanceKm: model.minDistanceKm,
      maxDistanceKm: model.maxDistanceKm,
      minElevationGain: model.minElevationGain,
      maxElevationGain: model.maxElevationGain,
    );
  }

  /// ApiResponseModel을 MyRouteList 엔티티로 변환
  static MyRouteList fromApiResponse(
    ApiResponseModel<MyRouteListDataModel> response,
  ) {
    final MyRouteListDataModel data = response.data;

    return MyRouteList(
      routes: data.routes.map(MyRouteMapper.fromModel).toList(),
      currentPage: data.pagination.currentPage,
      totalPages: data.pagination.totalPages,
      totalElements: data.pagination.totalElements,
      size: data.pagination.size,
      hasNext: data.pagination.hasNext,
      hasPrevious: data.pagination.hasPrevious,
    );
  }
}
