import 'package:health_kit_reporter/model/payload/quantity.dart';
import 'package:health_kit_reporter/model/payload/workout.dart';
import 'package:health_kit_reporter/model/payload/workout_route.dart';

import '../../domain/entities/cycling_workout_record.dart';
import '../../domain/entities/distance_data.dart';
import '../../domain/entities/heart_rate_data.dart';
import '../../domain/entities/location_data.dart';
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

    //각 운동에 대해 상세 데이터 조회 및 조합
    final List<CyclingWorkoutRecord> enrichedWorkouts =
        <CyclingWorkoutRecord>[];

    for (int i = 0; i < workouts.length; i++) {
      final Workout workout = workouts[i];

      CyclingWorkoutRecord record = HealthKitMapper.basicWorkoutRecord(workout);

      // 심박수 데이터 조회 시도
      final List<Quantity> heartRateQuantities = await _dataSource
          .getHeartRateDataForWorkout(
            workoutStartTime: record.startTime,
            workoutEndTime: record.endTime,
          );

      final List<HeartRateData> heartRateData =
          HealthKitMapper.toHeartRateDataList(heartRateQuantities);

      record = HealthKitMapper.addHeartRateData(record, heartRateData);

      // 거리 데이터 조회 시도
      final List<Quantity> distanceQuantities = await _dataSource
          .getDistanceDataForWorkout(
            workoutStartTime: record.startTime,
            workoutEndTime: record.endTime,
          );

      final List<DistanceData> distanceData =
          HealthKitMapper.toDistanceDataList(distanceQuantities);
      record = HealthKitMapper.addDistanceData(record, distanceData);

      // GPS 경로 데이터 조회 시도
      final List<WorkoutRoute> routes = await _dataSource
          .getWorkoutRouteForWorkout(
            workoutId: record.id,
            workoutStartTime: record.startTime,
            workoutEndTime: record.endTime,
          );

      final List<LocationData> locationData =
          HealthKitMapper.toLocationDataList(routes);

      record = HealthKitMapper.addLocationData(record, locationData);

      enrichedWorkouts.add(record);
    }

    return enrichedWorkouts;
  }
}
