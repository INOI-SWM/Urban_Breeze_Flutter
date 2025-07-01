class LocationData {
  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude,
    this.speed,
    this.accuracy,
  });

  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;

  final double? accuracy;
  final DateTime timestamp;

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, alt: $altitude, time: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.altitude == altitude &&
        other.speed == speed &&
        other.accuracy == accuracy &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^
        longitude.hashCode ^
        altitude.hashCode ^
        speed.hashCode ^
        accuracy.hashCode ^
        timestamp.hashCode;
  }
}
