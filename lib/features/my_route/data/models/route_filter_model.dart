enum ApiRouteSortType {
  createdAtDesc('CREATED_AT_DESC'),
  createdAtAsc('CREATED_AT_ASC'),
  distanceDesc('DISTANCE_DESC'),
  distanceAsc('DISTANCE_ASC'),
  elevationGainDesc('ELEVATION_GAIN_DESC'),
  elevationGainAsc('ELEVATION_GAIN_ASC');

  const ApiRouteSortType(this.value);
  final String value;
}

class RouteFilterModel {
  const RouteFilterModel({
    this.page = 0,
    this.size = 10,
    this.sortType = ApiRouteSortType.createdAtDesc,
    this.relationTypes = '',
    this.minDistanceKm = 0,
    this.maxDistanceKm = 100,
    this.minElevationGain = 0,
    this.maxElevationGain = 100,
  });

  final int page;
  final int size;
  final ApiRouteSortType sortType;
  final String relationTypes;
  final double minDistanceKm;
  final double maxDistanceKm;
  final double minElevationGain;
  final double maxElevationGain;

  Map<String, String> toQueryParameters() {
    return <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortType': sortType.value,
      'relationTypes': relationTypes,
      'minDistanceKm': minDistanceKm.toString(),
      'maxDistanceKm': maxDistanceKm.toString(),
      'minElevationGain': minElevationGain.toString(),
      'maxElevationGain': maxElevationGain.toString(),
    };
  }

  RouteFilterModel copyWith({
    int? page,
    int? size,
    ApiRouteSortType? sortType,
    String? relationTypes,
    double? minDistanceKm,
    double? maxDistanceKm,
    double? minElevationGain,
    double? maxElevationGain,
  }) {
    return RouteFilterModel(
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
}
