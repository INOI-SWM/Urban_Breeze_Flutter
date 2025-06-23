class RouteApiResponseModel {
  const RouteApiResponseModel({
    required this.coordinates,
    required this.distance,
    required this.duration,
    required this.rawAscent,
    required this.rawDescent,
    this.bbox,
  });

  factory RouteApiResponseModel.fromJson(Map<String, dynamic> json) {
    final List<List<dynamic>> coordinates =
        (json['features'][0]['geometry']['coordinates'] as List<dynamic>)
            .cast<List<dynamic>>();

    final Map<String, dynamic> properties =
        json['features'][0]['properties'] as Map<String, dynamic>;
    final Map<String, dynamic> summary =
        properties['summary'] as Map<String, dynamic>;

    List<double>? bbox;
    if (json['bbox'] != null) {
      final List<double> rawBbox =
          (json['bbox'] as List<dynamic>)
              .map<double>((dynamic value) => (value as num).toDouble())
              .toList();

      if (rawBbox.length == 6) {
        bbox = <double>[rawBbox[0], rawBbox[1], rawBbox[3], rawBbox[4]];
      } else if (rawBbox.length == 4) {
        bbox = rawBbox;
      }
    }

    return RouteApiResponseModel(
      coordinates: coordinates,
      distance: (summary['distance'] as num).toDouble(),
      duration: (summary['duration'] as num).toDouble(),
      rawAscent: (properties['ascent'] as num?)?.toDouble() ?? 0.0,
      rawDescent: (properties['descent'] as num?)?.toDouble() ?? 0.0,
      bbox: bbox,
    );
  }

  /// 원시 좌표 데이터 [longitude, latitude, elevation]
  final List<List<dynamic>> coordinates;
  final double distance; // 단위 : 미터
  final double duration; // 단위 : 초
  final double rawAscent; // ORS 원시 총 상승고도(미터)
  final double rawDescent; // 총 하강고도(미터)

  /// 경로를 포함하는 경계 상자 [minLng, minLat, maxLng, maxLat]
  final List<double>? bbox;
}
