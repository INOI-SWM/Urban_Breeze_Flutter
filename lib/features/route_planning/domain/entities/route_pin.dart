import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/waypoint.dart';

/// 경로 계획 시 사용자가 찍는 핀 정보
/// 위치 정보와 선택적으로 waypoint 정보를 포함합니다.
class RoutePin {
  const RoutePin({required this.position, this.waypoint});

  final LatLng position;
  final Waypoint? waypoint;

  /// waypoint 정보를 업데이트한 새로운 RoutePin을 생성합니다.
  RoutePin copyWithWaypoint(Waypoint? waypoint) {
    return RoutePin(position: position, waypoint: waypoint);
  }

  /// 위치 또는 waypoint 정보를 업데이트한 새로운 RoutePin을 생성합니다.
  RoutePin copyWith({LatLng? position, Waypoint? waypoint}) {
    return RoutePin(
      position: position ?? this.position,
      waypoint: waypoint ?? this.waypoint,
    );
  }

  /// waypoint가 설정되어 있는지 확인합니다.
  bool get hasWaypoint => waypoint != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoutePin &&
        other.position == position &&
        other.waypoint == waypoint;
  }

  @override
  int get hashCode => Object.hash(position, waypoint);

  @override
  String toString() {
    return 'RoutePin(position: $position, waypoint: $waypoint)';
  }
}
