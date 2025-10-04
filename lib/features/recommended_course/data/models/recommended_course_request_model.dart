enum ApiRecommendedCourseSortType {
  nearest('NEAREST'),
  distanceLong('DISTANCE_LONG'),
  distanceShort('DISTANCE_SHORT'),
  difficultyHigh('DIFFICULTY_HIGH'),
  difficultyLow('DIFFICULTY_LOW');

  const ApiRecommendedCourseSortType(this.value);
  final String value;
}

class RecommendedCourseRequestModel {
  const RecommendedCourseRequestModel({
    this.page,
    this.size,
    this.sortType,
    this.recommendationTypes,
    this.regions,
    this.minDistanceM,
    this.maxDistanceM,
    this.minElevationGain,
    this.maxElevationGain,
    this.difficulties,
    this.userLon,
    this.userLat,
  });

  final int? page;
  final int? size;
  final String? sortType;
  final List<String>? recommendationTypes;
  final List<String>? regions;
  final double? minDistanceM;
  final double? maxDistanceM;
  final double? minElevationGain;
  final double? maxElevationGain;
  final List<String>? difficulties;
  final double? userLon;
  final double? userLat;

  /// API 요청시 사용할 쿼리 파라미터로 변환
  Map<String, String> toQueryParameters() {
    final Map<String, String> params = <String, String>{};

    // 필수 파라미터들 (null이 아닐 때만 추가)
    if (page != null) {
      params['page'] = page.toString();
    }
    if (size != null) {
      params['size'] = size.toString();
    }
    if (sortType != null) {
      params['sortType'] = sortType!;
    }

    // 선택적 파라미터들
    if (recommendationTypes != null && recommendationTypes!.isNotEmpty) {
      params['recommendationTypes'] = recommendationTypes!.join(',');
    }
    if (regions != null && regions!.isNotEmpty) {
      params['regions'] = regions!.join(',');
    }
    if (minDistanceM != null) {
      params['minDistanceM'] = minDistanceM.toString();
    }
    if (maxDistanceM != null) {
      params['maxDistanceM'] = maxDistanceM.toString();
    }
    if (minElevationGain != null) {
      params['minElevationGain'] = minElevationGain.toString();
    }
    if (maxElevationGain != null) {
      params['maxElevationGain'] = maxElevationGain.toString();
    }
    if (difficulties != null && difficulties!.isNotEmpty) {
      params['difficulties'] = difficulties!.join(',');
    }
    if (userLon != null) {
      params['userLon'] = userLon.toString();
    }
    if (userLat != null) {
      params['userLat'] = userLat.toString();
    }

    return params;
  }
}
