import 'package:ridingmate/features/my_route/domain/enums/route_sort_type.dart';

class MyRouteFilter {
  factory MyRouteFilter.defaultFilter() {
    return const MyRouteFilter();
  }
  const MyRouteFilter({
    this.page = 0,
    this.size = 10,
    this.sortType = RouteSortType.newest,
    this.relationTypes = '',
    this.minDistanceKm = 0,
    this.maxDistanceKm = 100,
    this.minElevationGain = 0,
    this.maxElevationGain = 100,
  });

  final int page;
  final int size;
  final RouteSortType sortType;
  final String relationTypes;
  final double minDistanceKm;
  final double maxDistanceKm;
  final double minElevationGain;
  final double maxElevationGain;

  /// 필터 업데이트
  MyRouteFilter copyWith({
    int? page,
    int? size,
    RouteSortType? sortType,
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
