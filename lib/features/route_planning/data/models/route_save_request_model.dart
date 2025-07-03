class RouteSaveRequestModel {
  const RouteSaveRequestModel({
    required this.name,
    required this.polyline,
    required this.distance,
    required this.duration,
    required this.elevationGain,
    required this.elevations,
    required this.bbox,
  });

  final String name;
  final String polyline;
  final double distance;
  final double duration;
  final double elevationGain;
  final List<double> elevations;
  final List<double> bbox;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': name,
      'polyline': polyline,
      'distance': distance,
      'duration': duration,
      'elevationGain': elevationGain,
    };
  }
}
