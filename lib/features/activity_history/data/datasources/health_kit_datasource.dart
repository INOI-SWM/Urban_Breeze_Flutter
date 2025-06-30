import 'package:health/health.dart';

import '../../domain/exceptions/health_kit_exceptions.dart';

class HealthKitDataSource {
  HealthKitDataSource({Health? health}) : _health = health ?? Health();
  final Health _health;

  static const List<HealthDataType> _dataTypes = <HealthDataType>[
    HealthDataType.WORKOUT,
    HealthDataType.HEART_RATE,
    HealthDataType.DISTANCE_CYCLING,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  Future<bool> requestPermissions() async {
    try {
      return await _health.requestAuthorization(_dataTypes);
    } catch (e) {
      throw HealthKitDataException('권한 요청 실패: $e');
    }
  }

  Future<bool> hasPermissions() async {
    try {
      // iOS에서는 READ 권한 상태를 직접 확인할 수 없으므로
      // 실제 데이터 조회를 시도해서 권한 상태를 간접적으로 확인
      final DateTime now = DateTime.now();
      final DateTime yesterday = now.subtract(const Duration(days: 1));

      // 작은 범위의 워크아웃 데이터 조회를 시도
      await _health.getHealthDataFromTypes(
        types: <HealthDataType>[HealthDataType.WORKOUT],
        startTime: yesterday,
        endTime: now,
      );

      // 조회가 성공하면 권한이 있는 것으로 판단 (빈 결과여도 OK)
      return true;
    } catch (e) {
      // 권한이 없으면 예외가 발생함

      return false;
    }
  }

  Future<List<HealthDataPoint>> getCyclingWorkouts({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final DateTime end = endDate ?? DateTime.now();
      final DateTime start =
          startDate ?? end.subtract(const Duration(days: 365));

      final List<HealthDataPoint> workouts = await _health
          .getHealthDataFromTypes(
            types: <HealthDataType>[HealthDataType.WORKOUT],
            startTime: start,
            endTime: end,
          );

      final List<HealthDataPoint> cyclingWorkouts =
          workouts.where((HealthDataPoint workout) {
            if (workout.value is WorkoutHealthValue) {
              final WorkoutHealthValue workoutValue =
                  workout.value as WorkoutHealthValue;
              return workoutValue.workoutActivityType ==
                  HealthWorkoutActivityType.BIKING;
            }
            return false;
          }).toList();

      cyclingWorkouts.sort(
        (HealthDataPoint a, HealthDataPoint b) =>
            b.dateFrom.compareTo(a.dateFrom),
      );

      return cyclingWorkouts;
    } catch (e) {
      if (e is HealthKitException) rethrow;
      throw HealthKitDataException('자전거 운동 데이터 조회 실패: $e');
    }
  }

  /// 특정 운동의 심박수 데이터를 조회합니다.
  Future<List<HealthDataPoint>> getHeartRateDataForWorkout({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  }) async {
    try {
      final List<HealthDataPoint> heartRateData = await _health
          .getHealthDataFromTypes(
            types: <HealthDataType>[HealthDataType.HEART_RATE],
            startTime: workoutStartTime,
            endTime: workoutEndTime,
          );

      heartRateData.sort(
        (HealthDataPoint a, HealthDataPoint b) =>
            a.dateFrom.compareTo(b.dateFrom),
      );

      return heartRateData;
    } catch (e) {
      if (e is HealthKitException) rethrow;
      throw HealthKitDataException('심박수 데이터 조회 실패: $e');
    }
  }

  Future<List<HealthDataPoint>> getDistanceDataForWorkout({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  }) async {
    try {
      final List<HealthDataPoint> distanceData = await _health
          .getHealthDataFromTypes(
            types: <HealthDataType>[HealthDataType.DISTANCE_CYCLING],
            startTime: workoutStartTime,
            endTime: workoutEndTime,
          );

      distanceData.sort(
        (HealthDataPoint a, HealthDataPoint b) =>
            a.dateFrom.compareTo(b.dateFrom),
      );

      return distanceData;
    } catch (e) {
      if (e is HealthKitException) rethrow;
      throw HealthKitDataException('거리 데이터 조회 실패: $e');
    }
  }
}
