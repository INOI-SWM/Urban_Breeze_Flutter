class RouteSaveRequestModel {
  const RouteSaveRequestModel({
    required this.title,
    required this.polyline,
    required this.distance,
    required this.duration, // 분
    required this.elevationGain,
    required this.geometry,
    required this.bbox,
  });

  final String title;
  final String polyline;
  final double distance;
  final int duration;
  final double elevationGain;
  final List<List<double>> geometry; // [longitude, latitude, elevation]
  final List<double> bbox;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'polyline': polyline,
      'distance': distance,
      'duration': duration,
      'elevationGain': elevationGain,
      'geometry': geometry,
      'bbox': bbox,
    };
  }
}
