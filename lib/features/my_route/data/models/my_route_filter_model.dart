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

class MyRouteFilterModel {
  const MyRouteFilterModel({
    this.page = 0,
    this.size = 10,
    this.sortType = ApiRouteSortType.createdAtDesc,
    this.relationTypes = '',
    this.minDistanceM,
    this.maxDistanceM,
    this.minElevationGain,
    this.maxElevationGain,
  });

  final int page;
  final int size;
  final ApiRouteSortType sortType;
  final String relationTypes;
  final double? minDistanceM;
  final double? maxDistanceM;
  final double? minElevationGain;
  final double? maxElevationGain;

  Map<String, String> toQueryParameters() {
    final Map<String, String> params = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortType': sortType.value,
      'relationTypes': relationTypes,
    };

    // Optional 파라미터들은 null이 아닐 때만 추가
    if (minDistanceM != null) {
      params['minDistanceM'] = minDistanceM!.toString();
    }
    if (maxDistanceM != null) {
      params['maxDistanceM'] = maxDistanceM!.toString();
    }
    if (minElevationGain != null) {
      params['minElevationGain'] = minElevationGain!.toString();
    }
    if (maxElevationGain != null) {
      params['maxElevationGain'] = maxElevationGain!.toString();
    }

    return params;
  }

  MyRouteFilterModel copyWith({
    int? page,
    int? size,
    ApiRouteSortType? sortType,
    String? relationTypes,
    double? minDistanceM,
    double? maxDistanceM,
    double? minElevationGain,
    double? maxElevationGain,
  }) {
    return MyRouteFilterModel(
      page: page ?? this.page,
      size: size ?? this.size,
      sortType: sortType ?? this.sortType,
      relationTypes: relationTypes ?? this.relationTypes,
      minDistanceM: minDistanceM ?? this.minDistanceM,
      maxDistanceM: maxDistanceM ?? this.maxDistanceM,
      minElevationGain: minElevationGain ?? this.minElevationGain,
      maxElevationGain: maxElevationGain ?? this.maxElevationGain,
    );
  }
}
