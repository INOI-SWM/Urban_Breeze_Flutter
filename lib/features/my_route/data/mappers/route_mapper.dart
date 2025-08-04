import 'package:ridingmate/features/my_route/data/models/route_filter_model.dart';
import 'package:ridingmate/features/my_route/data/models/route_list_data_model.dart';
import 'package:ridingmate/features/my_route/data/models/route_model.dart';
import 'package:ridingmate/features/my_route/domain/entities/route.dart';
import 'package:ridingmate/features/my_route/domain/entities/route_filter.dart';
import 'package:ridingmate/features/my_route/domain/entities/route_list.dart';
import 'package:ridingmate/features/my_route/domain/enums/route_sort_type.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

class RouteMapper {
  /// RouteModel을 Route 엔티티로 변환
  static Route fromModel(RouteModel model) {
    return Route(
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

  /// RouteFilter를 RouteFilterModel로 변환
  static RouteFilterModel toFilterModel(RouteFilter filter) {
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

  /// ApiResponseModel을 RouteList 엔티티로 변환
  static RouteList fromApiResponse(
    ApiResponseModel<RouteListDataModel> response,
  ) {
    final RouteListDataModel data = response.data;

    return RouteList(
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
