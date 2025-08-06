import '../../domain/entities/distance_data.dart';
import '../../domain/entities/heart_rate_data.dart';
import '../../domain/entities/location_data.dart';
import '../../domain/entities/workout_record.dart';

class GoogleHealthConnectMapper {
  /// 기본 운동 기록을 WorkoutRecord로 변환
  static WorkoutRecord basicWorkoutRecord(Map<String, dynamic> workout) {
    final int startTime = workout['startTime'] as int;
    final int endTime = workout['endTime'] as int;
    final double calories = (workout['calories'] as num?)?.toDouble() ?? 0.0;

    return WorkoutRecord(
      id: workout['id'] as String? ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(startTime),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTime),
      duration: Duration(milliseconds: endTime - startTime),
      distance: 0.0, // Health Connect에서 별도로 조회
      calories: calories, // 운동 세션에서 제공되는 칼로리 사용
      heartRateData: <HeartRateData>[],
      distanceData: <DistanceData>[],
      locationData: <LocationData>[],
    );
  }

  /// 심박수 데이터를 HeartRateData 리스트로 변환
  static List<HeartRateData> toHeartRateDataList(
    List<Map<String, dynamic>> heartRateData,
  ) {
    return heartRateData.map((Map<String, dynamic> data) {
      return HeartRateData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          data['timestamp'] as int,
        ),
        heartRate:
            (data['heartRate'] as num?)?.toInt() ??
            (data['value'] as num?)?.toInt() ??
            0,
      );
    }).toList();
  }

  /// 거리 데이터를 DistanceData 리스트로 변환
  static List<DistanceData> toDistanceDataList(
    List<Map<String, dynamic>> distanceData,
  ) {
    return distanceData.map((Map<String, dynamic> data) {
      return DistanceData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          data['timestamp'] as int,
        ),
        distance: (data['distanceMeters'] as num).toDouble(), // 미터 단위 사용
      );
    }).toList();
  }

  /// 위치 데이터를 LocationData 리스트로 변환
  static List<LocationData> toLocationDataList(
    List<Map<String, dynamic>> locationData,
  ) {
    return locationData.map((Map<String, dynamic> data) {
      return LocationData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          data['timestamp'] as int,
        ),
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        altitude: (data['altitude'] as num?)?.toDouble(),
        horizontalAccuracy: (data['accuracy'] as num?)?.toDouble(),
      );
    }).toList();
  }
}
