import 'package:urban_breeze/features/route_planning/domain/entities/route_pin.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_segment.dart';

/// 계획 중인 경로 전체를 관리하는 엔티티
///
/// 핀과 세그먼트의 관계:
/// - 완성된 상태: pins.length = segments.length + 1
/// - 중간 상태: 핀 추가 후 세그먼트 생성 전, pins.length > segments.length + 1 가능
class PlannedRoute {
  PlannedRoute({required this.pins, required this.segments, this.title})
    : assert(
        segments.length <= pins.length,
        'segments count must be less than or equal to pins count',
      );

  final List<RoutePin> pins; // 모든 핀들
  final List<RouteSegment> segments; // 핀들 사이의 세그먼트들
  final String? title; // 경로 제목 (저장 시 필요)

  /// 새로운 핀을 추가합니다.
  PlannedRoute addPin(RoutePin pin) {
    return PlannedRoute(pins: <RoutePin>[...pins, pin], segments: segments);
  }

  /// 새로운 세그먼트를 추가하고, 마지막 두 핀의 위치를 세그먼트 기준으로 업데이트합니다.
  PlannedRoute addSegment(RouteSegment segment) {
    if (pins.length < 2) {
      return PlannedRoute(
        pins: pins,
        segments: <RouteSegment>[...segments, segment],
      );
    }

    // 서버에서 받은 정확한 위치로 마지막 두 핀 업데이트
    final List<RoutePin> newPins = List<RoutePin>.from(pins);
    newPins[newPins.length - 2] = RoutePin(
      position: segment.points.first,
      waypoint: newPins[newPins.length - 2].waypoint,
    );
    newPins[newPins.length - 1] = RoutePin(
      position: segment.points.last,
      waypoint: newPins[newPins.length - 1].waypoint,
    );

    return PlannedRoute(
      pins: newPins,
      segments: <RouteSegment>[...segments, segment],
    );
  }

  /// 마지막 핀을 제거합니다.
  PlannedRoute removeLastPin({bool removeSegment = true}) {
    final List<RoutePin> newPins = List<RoutePin>.from(pins)..removeLast();
    final List<RouteSegment> newSegments =
        removeSegment && segments.isNotEmpty
            ? (List<RouteSegment>.from(segments)..removeLast())
            : segments;

    return PlannedRoute(pins: newPins, segments: newSegments);
  }

  /// 특정 인덱스의 핀에 waypoint를 설정합니다.
  PlannedRoute updatePinWaypoint(int index, RoutePin updatedPin) {
    final List<RoutePin> newPins = List<RoutePin>.from(pins);
    newPins[index] = updatedPin;

    return PlannedRoute(pins: newPins, segments: segments);
  }

  /// 경로를 초기화합니다.
  PlannedRoute clear() {
    return PlannedRoute(pins: <RoutePin>[], segments: <RouteSegment>[]);
  }

  /// 경로 제목을 설정합니다.
  PlannedRoute withTitle(String title) {
    return PlannedRoute(pins: pins, segments: segments, title: title);
  }

  /// 경로가 비어있는지 확인합니다.
  bool get isEmpty => pins.isEmpty;

  /// 경로가 비어있지 않은지 확인합니다.
  bool get isNotEmpty => pins.isNotEmpty;

  /// 총 거리를 계산합니다 (미터).
  double get totalDistance {
    return segments.fold(
      0.0,
      (double sum, RouteSegment segment) => sum + segment.distance,
    );
  }

  /// 총 소요 시간을 계산합니다 (초).
  int get totalDuration {
    return segments.fold(
      0,
      (int sum, RouteSegment segment) => sum + segment.duration,
    );
  }

  /// 총 상승 고도를 계산합니다 (미터).
  double get totalElevationGain {
    return segments.fold(
      0.0,
      (double sum, RouteSegment segment) => sum + segment.elevationGain,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlannedRoute &&
        other.pins.length == pins.length &&
        other.segments.length == segments.length;
  }

  @override
  int get hashCode => Object.hash(pins.length, segments.length);

  @override
  String toString() {
    return 'PlannedRoute(pins: ${pins.length}, segments: ${segments.length})';
  }
}
