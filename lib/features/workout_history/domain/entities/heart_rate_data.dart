class HeartRateData {
  const HeartRateData({required this.timestamp, required this.heartRate});
  final DateTime timestamp;
  final int heartRate;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeartRateData &&
        other.timestamp == timestamp &&
        other.heartRate == heartRate;
  }

  @override
  int get hashCode => Object.hash(timestamp, heartRate);

  @override
  String toString() {
    return 'HeartRateData{'
        'timestamp: $timestamp, '
        'heartRate: ${heartRate}bpm'
        '}';
  }
}
