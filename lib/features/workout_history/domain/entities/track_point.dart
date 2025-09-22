class TrackPoint {
  const TrackPoint({
    required this.index,
    required this.elevation,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heartRate,
  });

  final int index;
  final double elevation; // m
  final double latitude;
  final double longitude;
  final double? speed; // km/h
  final int? heartRate; // bpm

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrackPoint &&
        other.index == index &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.elevation == elevation &&
        other.speed == speed &&
        other.heartRate == heartRate;
  }

  @override
  int get hashCode =>
      Object.hash(index, latitude, longitude, elevation, speed, heartRate);

  @override
  String toString() {
    return 'TrackPoint(index: $index, lat: $latitude, lng: $longitude, elevation: $elevation, speed: $speed, heartRate: $heartRate)';
  }
}
