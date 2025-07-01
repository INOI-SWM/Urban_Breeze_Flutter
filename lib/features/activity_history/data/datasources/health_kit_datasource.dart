import 'package:health_kit_reporter/health_kit_reporter.dart';
import 'package:health_kit_reporter/model/payload/preferred_unit.dart';
import 'package:health_kit_reporter/model/payload/quantity.dart';
import 'package:health_kit_reporter/model/payload/workout.dart';
import 'package:health_kit_reporter/model/payload/workout_activity_type.dart';
import 'package:health_kit_reporter/model/predicate.dart';
import 'package:health_kit_reporter/model/type/quantity_type.dart';
import 'package:health_kit_reporter/model/type/workout_type.dart';

import '../../domain/exceptions/health_kit_exceptions.dart';

class HealthKitDataSource {
  HealthKitDataSource();

  static final List<String> _readTypes = <String>[
    WorkoutType.workoutType.identifier,
    QuantityType.heartRate.identifier,
    QuantityType.distanceCycling.identifier,
    QuantityType.activeEnergyBurned.identifier,
  ];

  Future<bool> requestPermissions() async {
    try {
      return await HealthKitReporter.requestAuthorization(
        _readTypes,
        <String>[],
      );
    } catch (e) {
      throw HealthKitDataException('권한 요청 실패: $e');
    }
  }

  Future<bool> hasPermissions() async {
    try {
      // health_kit_reporter에서는 권한 상태를 직접 확인할 수 없으므로
      // 실제 데이터 조회를 시도해서 권한 상태를 간접적으로 확인
      final DateTime now = DateTime.now();
      final DateTime yesterday = now.subtract(const Duration(days: 1));
      final Predicate predicate = Predicate(yesterday, now);

      // 작은 범위의 워크아웃 데이터 조회를 시도
      await HealthKitReporter.workoutQuery(predicate);

      // 조회가 성공하면 권한이 있는 것으로 판단 (빈 결과여도 OK)
      return true;
    } catch (e) {
      // 권한이 없으면 예외가 발생함
      return false;
    }
  }

  Future<List<Workout>> getCyclingWorkouts({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final DateTime end = endDate ?? DateTime.now();
      final DateTime start =
          startDate ?? end.subtract(const Duration(days: 365));

      final Predicate predicate = Predicate(start, end);
      final List<Workout> workouts = await HealthKitReporter.workoutQuery(
        predicate,
      );

      final List<Workout> cyclingWorkouts =
          workouts.where((Workout workout) {
            final WorkoutHarmonized harmonized = workout.harmonized;
            final WorkoutActivityType type = harmonized.type;
            return type == WorkoutActivityType.cycling;
          }).toList();

      // 최신순으로 정렬
      cyclingWorkouts.sort(
        (Workout a, Workout b) => DateTime.fromMillisecondsSinceEpoch(
          b.startTimestamp.toInt(),
        ).compareTo(
          DateTime.fromMillisecondsSinceEpoch(a.startTimestamp.toInt()),
        ),
      );

      return cyclingWorkouts;
    } catch (e) {
      if (e is HealthKitException) rethrow;
      throw HealthKitDataException('자전거 운동 데이터 조회 실패: $e');
    }
  }

  Future<List<Quantity>> getHeartRateDataForWorkout({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  }) async {
    try {
      final Predicate predicate = Predicate(workoutStartTime, workoutEndTime);
      final List<PreferredUnit> preferredUnits =
          await HealthKitReporter.preferredUnits(<QuantityType>[
            QuantityType.heartRate,
          ]);

      if (preferredUnits.isEmpty) {
        throw HealthKitDataException('심박수 단위를 가져올 수 없습니다');
      }

      final String unit = preferredUnits.first.unit;
      final List<Quantity> heartRateData =
          await HealthKitReporter.quantityQuery(
            QuantityType.heartRate,
            unit,
            predicate,
          );

      heartRateData.sort(
        (Quantity a, Quantity b) => DateTime.fromMillisecondsSinceEpoch(
          a.startTimestamp.toInt(),
        ).compareTo(
          DateTime.fromMillisecondsSinceEpoch(b.startTimestamp.toInt()),
        ),
      );

      return heartRateData;
    } catch (e) {
      if (e is HealthKitException) rethrow;
      throw HealthKitDataException('심박수 데이터 조회 실패: $e');
    }
  }

  Future<List<Quantity>> getDistanceDataForWorkout({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  }) async {
    try {
      final Predicate predicate = Predicate(workoutStartTime, workoutEndTime);
      final List<PreferredUnit> preferredUnits =
          await HealthKitReporter.preferredUnits(<QuantityType>[
            QuantityType.distanceCycling,
          ]);

      if (preferredUnits.isEmpty) {
        throw HealthKitDataException('거리 단위를 가져올 수 없습니다');
      }

      final String unit = preferredUnits.first.unit;
      final List<Quantity> distanceData = await HealthKitReporter.quantityQuery(
        QuantityType.distanceCycling,
        unit,
        predicate,
      );

      distanceData.sort(
        (Quantity a, Quantity b) => DateTime.fromMillisecondsSinceEpoch(
          a.startTimestamp.toInt(),
        ).compareTo(
          DateTime.fromMillisecondsSinceEpoch(b.startTimestamp.toInt()),
        ),
      );

      return distanceData;
    } catch (e) {
      if (e is HealthKitException) rethrow;
      throw HealthKitDataException('거리 데이터 조회 실패: $e');
    }
  }
}
