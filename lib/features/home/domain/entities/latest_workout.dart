class LatestWorkout {
  const LatestWorkout({
    required this.id,
    required this.title,
    required this.distance,
    required this.duration,
    required this.startedAt,
    this.thumbnailImageUrl,
    this.elevationGain,
  });

  final String id;
  final String title;
  final double distance; // km
  final int duration; // seconds
  final DateTime startedAt;
  final String? thumbnailImageUrl;
  final double? elevationGain; // meters

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LatestWorkout &&
        other.id == id &&
        other.title == title &&
        other.distance == distance &&
        other.duration == duration &&
        other.startedAt == startedAt &&
        other.thumbnailImageUrl == thumbnailImageUrl &&
        other.elevationGain == elevationGain;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    distance,
    duration,
    startedAt,
    thumbnailImageUrl,
    elevationGain,
  );

  @override
  String toString() {
    return 'LatestWorkout('
        'id: $id, '
        'title: $title, '
        'distance: $distance km, '
        'duration: $duration seconds, '
        'startedAt: $startedAt, '
        'elevationGain: $elevationGain m'
        ')';
  }
}
