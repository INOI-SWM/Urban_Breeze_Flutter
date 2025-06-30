class CyclingWorkoutRecord {
  const CyclingWorkoutRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.distance,
    required this.calories,
    this.averageSpeed,
    this.maxSpeed,
    this.maxHeartRate,
  });
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final double distance; // 미터 단위
  final double calories; // kcal 단위
  final double? averageSpeed; // km/h 단위
  final double? maxSpeed; // km/h 단위
  final int? maxHeartRate;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CyclingWorkoutRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CyclingWorkoutRecord{'
        'id: $id, '
        'duration: $duration, '
        'distance: ${distance}m, '
        'calories: ${calories}kcal, '
        'maxSpeed: ${maxSpeed}km/h, '
        'averageSpeed: ${averageSpeed}km/h, '
        'maxHeartRate: ${maxHeartRate}bpm'
        '}';
  }
}
