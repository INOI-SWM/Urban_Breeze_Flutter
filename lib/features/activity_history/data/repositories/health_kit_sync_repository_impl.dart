import 'package:health_kit_reporter/model/payload/quantity.dart';
import 'package:health_kit_reporter/model/payload/workout.dart';

import '../../domain/entities/cycling_workout_record.dart';
import '../../domain/entities/distance_data.dart';
import '../../domain/entities/heart_rate_data.dart';
import '../../domain/repositories/health_kit_sync_repository.dart';
import '../datasources/health_kit_datasource.dart';
import '../mappers/health_kit_mapper.dart';

class HealthKitSyncRepositoryImpl implements HealthKitSyncRepository {
  HealthKitSyncRepositoryImpl({HealthKitDataSource? dataSource})
    : _dataSource = dataSource ?? HealthKitDataSource();
  final HealthKitDataSource _dataSource;

  @override
  Future<bool> requestPermissions() async {
    return await _dataSource.requestPermissions();
  }

  @override
  Future<bool> hasPermissions() async {
    return await _dataSource.hasPermissions();
  }

  @override
  Future<List<CyclingWorkoutRecord>> fetchCyclingWorkoutsFromHealthKit({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<Workout> workouts = await _dataSource.getCyclingWorkouts(
      startDate: startDate,
      endDate: endDate,
    );

    return HealthKitMapper.toCyclingWorkoutRecordList(workouts);
  }

  @override
  Future<List<HeartRateData>> fetchHeartRateDataFromHealthKit({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  }) async {
    final List<Quantity> quantities = await _dataSource
        .getHeartRateDataForWorkout(
          workoutStartTime: workoutStartTime,
          workoutEndTime: workoutEndTime,
        );

    return HealthKitMapper.toHeartRateDataList(quantities);
  }

  @override
  Future<List<DistanceData>> fetchDistanceDataFromHealthKit({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  }) async {
    final List<Quantity> quantities = await _dataSource
        .getDistanceDataForWorkout(
          workoutStartTime: workoutStartTime,
          workoutEndTime: workoutEndTime,
        );

    return HealthKitMapper.toDistanceDataList(quantities);
  }
}
