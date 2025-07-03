class DistanceData {
  const DistanceData({required this.timestamp, required this.distance});
  final DateTime timestamp;
  final double distance;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DistanceData &&
        other.timestamp == timestamp &&
        other.distance == distance;
  }

  @override
  int get hashCode => Object.hash(timestamp, distance);

  @override
  String toString() {
    return 'DistanceData{'
        'timestamp: $timestamp, '
        'distance: ${distance}m'
        '}';
  }
}
