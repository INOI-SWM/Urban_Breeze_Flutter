class HomeStatistics {
  const HomeStatistics({
    required this.totalDistance,
    required this.totalDuration,
    required this.totalWorkouts,
  });

  final double totalDistance; // km
  final int totalDuration; // seconds
  final int totalWorkouts;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeStatistics &&
        other.totalDistance == totalDistance &&
        other.totalDuration == totalDuration &&
        other.totalWorkouts == totalWorkouts;
  }

  @override
  int get hashCode => Object.hash(totalDistance, totalDuration, totalWorkouts);

  @override
  String toString() {
    return 'HomeStatistics('
        'totalDistance: $totalDistance km, '
        'totalDuration: $totalDuration seconds, '
        'totalWorkouts: $totalWorkouts'
        ')';
  }
}
