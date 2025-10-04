import 'package:urban_breeze/features/route_planning/data/models/geometry_point_model.dart';

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
  final List<GeometryPointModel> geometry; // JSON 객체 배열
  final List<double> bbox;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'polyline': polyline,
      'distance': distance,
      'duration': duration,
      'elevationGain': elevationGain,
      'geometry':
          geometry.map((GeometryPointModel point) => point.toJson()).toList(),
      'bbox': bbox,
    };
  }
}
