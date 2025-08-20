class RecommendedCourseRequestModel {
  const RecommendedCourseRequestModel({
    required this.page,
    required this.size,
    required this.sortType,
    this.regions,
    this.difficulty,
    this.recommendationTypes,
    required this.minDistance,
    required this.maxDistance,
    required this.minElevation,
    required this.maxElevation,
    this.userLon,
    this.userLat,
  });

  final int page;
  final int size;
  final String sortType;
  final List<String>? recommendationTypes;
  final List<String>? regions;
  final double minDistance;
  final double maxDistance;
  final double minElevation;
  final double maxElevation;
  final List<String>? difficulty;
  final double? userLon;
  final double? userLat;

  /// API 요청시 사용할 쿼리 파라미터로 변환
  Map<String, String> toQueryParameters() {
    final Map<String, String> params = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortType': sortType,
      'minDistance': minDistance.toString(),
      'maxDistance': maxDistance.toString(),
      'minElevation': minElevation.toString(),
      'maxElevation': maxElevation.toString(),
    };

    if (regions != null && regions!.isNotEmpty) {
      params['regions'] = regions!.join(',');
    }
    if (difficulty != null && difficulty!.isNotEmpty) {
      params['difficulty'] = difficulty!.join(',');
    }
    if (recommendationTypes != null && recommendationTypes!.isNotEmpty) {
      params['recommendationTypes'] = recommendationTypes!.join(',');
    }
    if (userLon != null) {
      params['userLon'] = userLon!.toString();
    }
    if (userLat != null) {
      params['userLat'] = userLat!.toString();
    }

    return params;
  }
}
