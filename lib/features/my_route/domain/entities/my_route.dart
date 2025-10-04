import 'package:urban_breeze/shared/utils/display_formatter.dart';

class MyRoute {
  const MyRoute({
    required this.routeId,
    required this.title,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.distance,
    required this.elevationGain,
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
  });

  final String routeId;
  final String title;
  final String thumbnailUrl;
  final DateTime createdAt;
  final double distance; // m 단위 (API에서 미터로 받음)
  final double elevationGain;
  final String userId;
  final String nickname;
  final String profileImageUrl;

  /// 거리 표시용 문자열 반환 (미터 → km)
  String get distanceDisplay =>
      DisplayFormatter.formatDistanceFromMeters(distance);

  /// 상승 고도 표시용 문자열 반환
  String get elevationGainDisplay =>
      DisplayFormatter.formatElevationGain(elevationGain);

  /// 생성일 표시용 문자열 반환
  String get createdAtDisplay => DisplayFormatter.formatDate(createdAt);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyRoute && other.routeId == routeId;
  }

  @override
  int get hashCode => routeId.hashCode;

  @override
  String toString() {
    return 'MyRoute(id: $routeId, title: $title, distance: $distance, elevationGain: $elevationGain)';
  }
}
