import 'package:urban_breeze/features/route_planning/domain/entities/geometry_point.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/waypoint.dart';

class GeometryPointModel {
  const GeometryPointModel({
    required this.longitude,
    required this.latitude,
    required this.elevation,
    this.waypoint,
  });

  factory GeometryPointModel.fromJson(Map<String, dynamic> json) {
    return GeometryPointModel(
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      elevation: (json['elevation'] as num).toDouble(),
      waypoint:
          json['waypoint'] != null
              ? Waypoint.fromJson(json['waypoint'] as Map<String, dynamic>)
              : null,
    );
  }

  factory GeometryPointModel.fromDomain(GeometryPoint domain) {
    return GeometryPointModel(
      longitude: domain.longitude,
      latitude: domain.latitude,
      elevation: domain.elevation,
      waypoint: domain.waypoint,
    );
  }

  final double longitude; // 경도
  final double latitude; // 위도
  final double elevation; // 경사도
  final Waypoint? waypoint; // waypoint 정보

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'longitude': longitude,
      'latitude': latitude,
      'elevation': elevation,
      if (waypoint != null) 'waypoint': waypoint!.toJson(),
    };
  }

  GeometryPoint toDomain() {
    return GeometryPoint(
      longitude: longitude,
      latitude: latitude,
      elevation: elevation,
      waypoint: waypoint,
    );
  }
}
