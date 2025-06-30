import 'package:health/health.dart';

import '../../domain/entities/cycling_workout_record.dart';
import '../../domain/entities/distance_data.dart';
import '../../domain/entities/heart_rate_data.dart';
import '../../domain/exceptions/health_kit_exceptions.dart';

class HealthKitMapper {
  /// HealthDataPoint(WORKOUT)를 CyclingWorkoutRecord로 변환
  static CyclingWorkoutRecord toCyclingWorkoutRecord(
    HealthDataPoint healthDataPoint,
  ) {
    if (healthDataPoint.value is! WorkoutHealthValue) {
      throw HealthKitDataException('WORKOUT 타입이 아닌 데이터입니다');
    }

    final WorkoutHealthValue workoutValue =
        healthDataPoint.value as WorkoutHealthValue;

    // WorkoutHealthValue에서 통계 데이터 추출
    final Map<String, dynamic> workoutData = workoutValue.toJson();

    return CyclingWorkoutRecord(
      id: '${healthDataPoint.dateFrom.millisecondsSinceEpoch}', // 시작 시간을 ID로 사용
      startTime: healthDataPoint.dateFrom,
      endTime: healthDataPoint.dateTo,
      duration: healthDataPoint.dateTo.difference(healthDataPoint.dateFrom),
      distance: _extractDistance(workoutData),
      calories: _extractCalories(workoutData),
      averageSpeed: _extractAverageSpeed(workoutData),
      maxSpeed: _extractMaxSpeed(workoutData),
      maxHeartRate: _extractMaxHeartRate(workoutData),
    );
  }

  /// HealthDataPoint(HEART_RATE)를 HeartRateData로 변환
  static HeartRateData toHeartRateData(HealthDataPoint healthDataPoint) {
    if (healthDataPoint.value is! NumericHealthValue) {
      throw HealthKitDataException('HEART_RATE 타입이 아닌 데이터입니다');
    }

    final NumericHealthValue numericValue =
        healthDataPoint.value as NumericHealthValue;

    return HeartRateData(
      timestamp: healthDataPoint.dateFrom,
      heartRate: numericValue.numericValue.round(),
    );
  }

  /// HealthDataPoint(DISTANCE_CYCLING)를 DistanceData로 변환
  static DistanceData toDistanceData(HealthDataPoint healthDataPoint) {
    if (healthDataPoint.value is! NumericHealthValue) {
      throw HealthKitDataException('DISTANCE_CYCLING 타입이 아닌 데이터입니다');
    }

    final NumericHealthValue numericValue =
        healthDataPoint.value as NumericHealthValue;

    return DistanceData(
      timestamp: healthDataPoint.dateFrom,
      distance: numericValue.numericValue.toDouble(),
    );
  }

  /// 리스트 변환 헬퍼 메서드들
  static List<CyclingWorkoutRecord> toCyclingWorkoutRecordList(
    List<HealthDataPoint> healthDataPoints,
  ) {
    return healthDataPoints
        .map((HealthDataPoint point) => toCyclingWorkoutRecord(point))
        .toList();
  }

  static List<HeartRateData> toHeartRateDataList(
    List<HealthDataPoint> healthDataPoints,
  ) {
    return healthDataPoints
        .map((HealthDataPoint point) => toHeartRateData(point))
        .toList();
  }

  static List<DistanceData> toDistanceDataList(
    List<HealthDataPoint> healthDataPoints,
  ) {
    return healthDataPoints
        .map((HealthDataPoint point) => toDistanceData(point))
        .toList();
  }

  // Private 헬퍼 메서드들 - WorkoutHealthValue JSON에서 데이터 추출
  static double _extractDistance(Map<String, dynamic> workoutData) {
    try {
      // totalDistance는 미터 단위로 저장됨
      return (workoutData['totalDistance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  static double _extractCalories(Map<String, dynamic> workoutData) {
    try {
      // totalEnergyBurned는 kcal 단위
      return (workoutData['totalEnergyBurned'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  static double? _extractAverageSpeed(Map<String, dynamic> workoutData) {
    try {
      // averageSpeed는 km/h 단위
      final num? avgSpeed = workoutData['averageSpeed'] as num?;
      return avgSpeed?.toDouble();
    } catch (e) {
      return null;
    }
  }

  static double? _extractMaxSpeed(Map<String, dynamic> workoutData) {
    try {
      // maxSpeed는 km/h 단위
      final num? maxSpeed = workoutData['maxSpeed'] as num?;
      return maxSpeed?.toDouble();
    } catch (e) {
      return null;
    }
  }

  static int? _extractMaxHeartRate(Map<String, dynamic> workoutData) {
    try {
      // maxHeartRate는 bpm 단위
      final num? maxHR = workoutData['maxHeartRate'] as num?;
      return maxHR?.round();
    } catch (e) {
      return null;
    }
  }
}
