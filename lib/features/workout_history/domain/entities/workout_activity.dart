class WorkoutActivity {
  const WorkoutActivity({
    required this.activityId,
    required this.title,
    required this.startedAt,
    required this.endedAt,
    required this.distance,
    required this.duration,
    required this.elevationGain,
    required this.thumbnailImageUrl,
    required this.userProfileImageUrl,
    required this.userNickname,
  });

  final String activityId;
  final String title;
  final DateTime startedAt;
  final DateTime endedAt;
  final double distance; // km 단위
  final int duration; // seconds
  final double elevationGain; // meters
  final String thumbnailImageUrl;
  final String userProfileImageUrl;
  final String userNickname;

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
        'distance: $distance km, '
        'duration: $duration seconds, '
        'elevationGain: $elevationGain m, '
        'userNickname: $userNickname'
        '}';
  }
}
