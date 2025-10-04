import 'package:urban_breeze/shared/utils/display_formatter.dart';

class WorkoutActivity {
  const WorkoutActivity({
    required this.activityId,
    required this.title,
    required this.startedAt,
    required this.endedAt,
    required this.distance,
    required this.duration,
    this.elevationGain,
    this.thumbnailImageUrl,
    required this.userProfileImageUrl,
    required this.userNickname,
  });

  final String activityId;
  final String title;
  final DateTime startedAt;
  final DateTime endedAt;
  final double distance; // m 단위 (API에서 미터로 받음)
  final int duration; // seconds
  final double? elevationGain; // meters
  final String? thumbnailImageUrl;
  final String userProfileImageUrl;
  final String userNickname;

  /// 거리 표시용 문자열 반환 (미터 → km)
  String get distanceDisplay =>
      DisplayFormatter.formatDistanceFromMeters(distance);

  /// 상승 고도 표시용 문자열 반환
  String get elevationGainDisplay =>
      DisplayFormatter.formatElevationGain(elevationGain);

  /// 운동 시간 표시용 문자열 반환
  String get durationDisplay =>
      DisplayFormatter.formatDurationFromSeconds(duration);

  /// 운동 시작일 표시용 문자열 반환
  String get startedAtDisplay => DisplayFormatter.formatDate(startedAt);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutActivity && other.activityId == activityId;
  }

  @override
  int get hashCode => activityId.hashCode;

  @override
  String toString() {
    return 'WorkoutActivity{'
        'activityId: $activityId, '
        'title: $title, '
        'startedAt: $startedAt, '
        'endedAt: $endedAt, '
        'distance: $distance m, '
        'duration: $duration seconds, '
        'elevationGain: $elevationGain m, '
        'userNickname: $userNickname'
        '}';
  }
}
