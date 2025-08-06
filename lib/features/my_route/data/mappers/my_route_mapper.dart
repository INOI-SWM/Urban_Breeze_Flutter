import 'package:ridingmate/features/my_route/data/models/my_route_filter_model.dart';
import 'package:ridingmate/features/my_route/data/models/my_route_list_data_model.dart';
import 'package:ridingmate/features/my_route/data/models/my_route_model.dart';
import 'package:ridingmate/features/my_route/domain/entities/my_route.dart';
import 'package:ridingmate/features/my_route/domain/entities/my_route_filter.dart';
import 'package:ridingmate/features/my_route/domain/entities/my_route_list.dart';
import 'package:ridingmate/features/my_route/domain/enums/my_route_sort_type.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

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

  /// 도메인 필터 모델을 서버 필터 모델로 변환
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

  /// 서버 필터 모델을 도메인 필터 모델로 변환
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
