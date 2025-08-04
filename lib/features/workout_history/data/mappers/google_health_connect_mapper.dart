import '../../domain/entities/distance_data.dart';
import '../../domain/entities/heart_rate_data.dart';
import '../../domain/entities/location_data.dart';
import '../../domain/entities/workout_record.dart';

class GoogleHealthConnectMapper {
  /// 기본 운동 기록을 WorkoutRecord로 변환
  static WorkoutRecord basicWorkoutRecord(Map<String, dynamic> workout) {
    final int startTime = workout['startTime'] as int;
    final int? endTime = workout['endTime'] as int?;

    return WorkoutRecord(
      id: workout['id'] as String? ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(startTime),
      endTime:
          endTime != null
              ? DateTime.fromMillisecondsSinceEpoch(endTime)
              : DateTime.fromMillisecondsSinceEpoch(startTime),
      duration:
          endTime != null
              ? Duration(milliseconds: endTime - startTime)
              : Duration.zero,
      distance: 0.0, // Health Connect에서 별도로 조회
      calories: 0.0, // Health Connect에서 별도로 조회
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
        heartRate: (data['value'] as num).toInt(),
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
        distance: (data['value'] as num).toDouble(),
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
