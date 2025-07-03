import 'distance_data.dart';
import 'heart_rate_data.dart';
import 'location_data.dart';

class CyclingWorkoutRecord {
  const CyclingWorkoutRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.distance,
    required this.calories,
    required this.heartRateData,
    required this.distanceData,
    required this.locationData,
  });

  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final double distance; // 미터 단위
  final double calories; // kcal 단위
  final List<HeartRateData> heartRateData; // 원시 심박수 데이터
  final List<DistanceData> distanceData; // 원시 거리 데이터
  final List<LocationData> locationData; // 원시 GPS 위치 데이터

  /// 기존 객체의 일부 필드만 변경한 새로운 객체를 생성
  CyclingWorkoutRecord copyWith({
    List<HeartRateData>? heartRateData,
    List<DistanceData>? distanceData,
    List<LocationData>? locationData,
  }) {
    return CyclingWorkoutRecord(
      id: id,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      distance: distance,
      calories: calories,
      heartRateData: heartRateData ?? this.heartRateData,
      distanceData: distanceData ?? this.distanceData,
      locationData: locationData ?? this.locationData,
    );
  }

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
        'heartRateData: ${heartRateData.length}개, '
        'distanceData: ${distanceData.length}개, '
        'locationData: ${locationData.length}개 포인트'
        '}';
  }
}
