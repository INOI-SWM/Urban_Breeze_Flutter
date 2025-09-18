class WorkoutActivity {
  const WorkoutActivity({
    required this.id,
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

  final int id;
  final String title;
  final DateTime startedAt;
  final DateTime endedAt;
  final double distance;
  final int duration; // seconds
  final double elevationGain; // meters
  final String thumbnailImageUrl;
  final String userProfileImageUrl;
  final String userNickname;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutActivity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WorkoutActivity{'
        'id: $id, '
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
