import 'package:flutter/material.dart';
import 'package:ridingmate/features/my_route/data/models/route_filter_model.dart';
import 'package:ridingmate/features/my_route/data/models/route_list_data_model.dart';
import 'package:ridingmate/features/my_route/data/models/route_model.dart';
import 'package:ridingmate/features/my_route/domain/entities/route.dart';
import 'package:ridingmate/features/my_route/domain/entities/route_filter.dart';
import 'package:ridingmate/features/my_route/domain/entities/route_list.dart';
import 'package:ridingmate/features/my_route/domain/enums/route_sort_type.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';

class RouteMapper {
  /// RouteModel을 MyRoute 엔티티로 변환
  static MyRoute fromModel(RouteModel model) {
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

  /// MyRouteFilter를 RouteFilterModel로 변환
  static RouteFilterModel toFilterModel(MyRouteFilter filter) {
    // 정렬 타입 변환
    ApiRouteSortType apiSortType;
    switch (filter.sortType) {
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

    return RouteFilterModel(
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
  static RouteFilterModel fromFilterData(
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

  /// RouteFilterModel을 MyRouteFilter로 변환
  static MyRouteFilter fromFilterModel(RouteFilterModel model) {
    // 정렬 타입 변환
    RouteSortType domainSortType;
    switch (model.sortType) {
      case ApiRouteSortType.createdAtDesc:
        domainSortType = RouteSortType.newest;
        break;
      case ApiRouteSortType.createdAtAsc:
        domainSortType = RouteSortType.oldest;
        break;
      case ApiRouteSortType.distanceDesc:
        domainSortType = RouteSortType.distanceLong;
        break;
      case ApiRouteSortType.distanceAsc:
        domainSortType = RouteSortType.distanceShort;
        break;
      case ApiRouteSortType.elevationGainDesc:
      case ApiRouteSortType.elevationGainAsc:
        domainSortType = RouteSortType.newest; // 기본값
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
    ApiResponseModel<RouteListDataModel> response,
  ) {
    final RouteListDataModel data = response.data;

    return MyRouteList(
      routes: data.routes.map(RouteMapper.fromModel).toList(),
      currentPage: data.pagination.currentPage,
      totalPages: data.pagination.totalPages,
      totalElements: data.pagination.totalElements,
      size: data.pagination.size,
      hasNext: data.pagination.hasNext,
      hasPrevious: data.pagination.hasPrevious,
    );
  }
}
