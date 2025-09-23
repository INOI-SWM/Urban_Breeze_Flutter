import 'package:urban_breeze/features/my_route/domain/enums/my_route_sort_type.dart';
import 'package:urban_breeze/shared/filter/models/base_filter.dart';

class MyRouteFilter extends BaseFilter {
  factory MyRouteFilter.defaultFilter() {
    return const MyRouteFilter();
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
