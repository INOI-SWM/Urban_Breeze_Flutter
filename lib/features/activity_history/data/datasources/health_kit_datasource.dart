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
      for (final HealthDataType dataType in _dataTypes) {
        final bool? status = await _health.hasPermissions(<HealthDataType>[
          dataType,
        ]);
        if (status != true) {
          return false;
        }
      }
      return true;
    } catch (e) {
      throw HealthKitDataException('권한 확인 실패: $e');
    }
  }

  Future<List<HealthDataPoint>> getCyclingWorkouts({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (!await hasPermissions()) {
        throw HealthKitPermissionException('HealthKit 권한이 필요합니다');
      }

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

  Future<List<HealthDataPoint>> getHeartRateData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (!await hasPermissions()) {
        throw HealthKitPermissionException('HealthKit 권한이 필요합니다');
      }

      final List<HealthDataPoint> heartRateData = await _health
          .getHealthDataFromTypes(
            types: <HealthDataType>[HealthDataType.HEART_RATE],
            startTime: startDate,
            endTime: endDate,
          );

      // 시간순 정렬
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

  Future<List<HealthDataPoint>> getDistanceData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (!await hasPermissions()) {
        throw HealthKitPermissionException('HealthKit 권한이 필요합니다');
      }

      final List<HealthDataPoint> distanceData = await _health
          .getHealthDataFromTypes(
            types: <HealthDataType>[HealthDataType.DISTANCE_CYCLING],
            startTime: startDate,
            endTime: endDate,
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
