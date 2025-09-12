import 'package:urban_breeze/features/route_planning/domain/entities/geometry_point.dart';

class GeometryPointModel {
  const GeometryPointModel({
    required this.longitude,
    required this.latitude,
    required this.elevation,
  });

  factory GeometryPointModel.fromJson(Map<String, dynamic> json) {
    return GeometryPointModel(
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      elevation: (json['elevation'] as num).toDouble(),
    );
  }

  factory GeometryPointModel.fromDomain(GeometryPoint domain) {
    return GeometryPointModel(
      longitude: domain.longitude,
      latitude: domain.latitude,
      elevation: domain.elevation,
    );
  }

  final double longitude; // 경도
  final double latitude; // 위도
  final double elevation; // 경사도

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'longitude': longitude,
      'latitude': latitude,
      'elevation': elevation,
    };
  }

  GeometryPoint toDomain() {
    return GeometryPoint(
      longitude: longitude,
      latitude: latitude,
      elevation: elevation,
    );
  }
}
