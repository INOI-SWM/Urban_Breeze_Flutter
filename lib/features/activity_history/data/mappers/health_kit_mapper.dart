import 'package:health_kit_reporter/model/payload/quantity.dart';
import 'package:health_kit_reporter/model/payload/workout.dart';
import 'package:health_kit_reporter/model/type/quantity_type.dart';

import '../../domain/entities/cycling_workout_record.dart';
import '../../domain/entities/distance_data.dart';
import '../../domain/entities/heart_rate_data.dart';
import '../../domain/exceptions/health_kit_exceptions.dart';

class HealthKitMapper {
  static CyclingWorkoutRecord toCyclingWorkoutRecord(Workout workout) {
    try {
      final WorkoutHarmonized harmonized = workout.harmonized;

      return CyclingWorkoutRecord(
        id: workout.uuid,
        startTime: DateTime.fromMillisecondsSinceEpoch(
          workout.startTimestamp.toInt(),
        ),
        endTime: DateTime.fromMillisecondsSinceEpoch(
          workout.endTimestamp.toInt(),
        ),
        duration: Duration(seconds: (workout.duration).toInt()),
        distance: harmonized.totalDistance?.toDouble() ?? 0.0,
        calories: harmonized.totalEnergyBurned?.toDouble() ?? 0.0,
        averageSpeed: null, // health_kit_reporter의 Workout에서 평균 속도는 직접 제공되지 않음
        maxSpeed: null, // health_kit_reporter의 Workout에서 최대 속도는 직접 제공되지 않음
        maxHeartRate: null, // 별도 심박수 데이터 조회 필요
      );
    } catch (e) {
      throw HealthKitDataException('워크아웃 데이터 변환 실패: $e');
    }
  }

  static HeartRateData toHeartRateData(Quantity quantity) {
    try {
      if (quantity.identifier != QuantityType.heartRate.identifier) {
        throw HealthKitDataException('HEART_RATE 타입이 아닌 데이터입니다');
      }

      return HeartRateData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          quantity.startTimestamp.toInt(),
        ),
        heartRate: quantity.harmonized.value.round(),
      );
    } catch (e) {
      throw HealthKitDataException('심박수 데이터 변환 실패: $e');
    }
  }

  static DistanceData toDistanceData(Quantity quantity) {
    try {
      if (quantity.identifier != QuantityType.distanceCycling.identifier) {
        throw HealthKitDataException('DISTANCE_CYCLING 타입이 아닌 데이터입니다');
      }

      return DistanceData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          quantity.startTimestamp.toInt(),
        ),
        distance: quantity.harmonized.value.toDouble(),
      );
    } catch (e) {
      throw HealthKitDataException('거리 데이터 변환 실패: $e');
    }
  }

  static List<CyclingWorkoutRecord> toCyclingWorkoutRecordList(
    List<Workout> workouts,
  ) {
    return workouts
        .map((Workout workout) => toCyclingWorkoutRecord(workout))
        .toList();
  }

  static List<HeartRateData> toHeartRateDataList(List<Quantity> quantities) {
    return quantities
        .map((Quantity quantity) => toHeartRateData(quantity))
        .toList();
  }

  static List<DistanceData> toDistanceDataList(List<Quantity> quantities) {
    return quantities
        .map((Quantity quantity) => toDistanceData(quantity))
        .toList();
  }
}
