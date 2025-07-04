class RouteApiResponseModel {
  factory RouteApiResponseModel.fromJson(Map<String, dynamic> jsonData) {
    List<double> bbox;
    final List<double> rawBbox =
        (jsonData['bbox'] as List<dynamic>)
            .map<double>((dynamic value) => (value as num).toDouble())
            .toList();

    if (rawBbox.length == 6) {
      bbox = <double>[rawBbox[0], rawBbox[1], rawBbox[3], rawBbox[4]];
    } else {
      bbox = rawBbox;
    }

    final List<List<double>> geometry =
        (jsonData['geometry'] as List<dynamic>)
            .map(
              (dynamic pt) =>
                  (pt as List<dynamic>)
                      .map((dynamic e) => (e as num).toDouble())
                      .toList(),
            )
            .toList();

    return RouteApiResponseModel(
      bbox: bbox,
      geometry: geometry,
      totalDuration: (jsonData['totalDuration'] as num).toInt(),
      totalDistance: (jsonData['totalDistance'] as num).toDouble(),
      averageGradient: (jsonData['averageGradient'] as num).toDouble(),
    );
  }

  const RouteApiResponseModel({
    required this.bbox,
    required this.geometry,
    required this.totalDuration, //분
    required this.totalDistance, //미터
    required this.averageGradient,
  });

  final List<double> bbox;
  final List<List<double>> geometry;
  final int totalDuration;
  final double totalDistance;
  final double averageGradient;
}
