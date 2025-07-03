import 'package:health_kit_reporter/model/payload/quantity.dart';
import 'package:health_kit_reporter/model/payload/workout.dart';
import 'package:health_kit_reporter/model/payload/workout_route.dart';

import '../../domain/entities/distance_data.dart';
import '../../domain/entities/heart_rate_data.dart';
import '../../domain/entities/location_data.dart';
import '../../domain/entities/workout_record.dart';
import '../../domain/repositories/health_kit_sync_repository.dart';
import '../datasources/apple_health_kit_datasource.dart';
import '../mappers/apple_health_kit_mapper.dart';

class AppleHealthKitSyncRepositoryImpl implements HealthKitSyncRepository {
  AppleHealthKitSyncRepositoryImpl({AppleHealthKitDataSource? dataSource})
    : _dataSource = dataSource ?? AppleHealthKitDataSource();
  final AppleHealthKitDataSource _dataSource;

  @override
  Future<bool> requestPermissions() async {
    return await _dataSource.requestPermissions();
  }

  @override
  Future<bool> hasPermissions() async {
    return await _dataSource.hasPermissions();
  }

  @override
  Future<List<WorkoutRecord>> fetchCyclingWorkoutsFromHealthKit({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<Workout> workouts = await _dataSource.getCyclingWorkouts(
      startDate: startDate,
      endDate: endDate,
    );

    final List<WorkoutRecord> enrichedWorkouts = <WorkoutRecord>[];

    for (int i = 0; i < workouts.length; i++) {
      final Workout workout = workouts[i];

      WorkoutRecord record = AppleHealthKitMapper.basicWorkoutRecord(workout);

      final List<Future<dynamic>> futures = <Future<dynamic>>[
        _dataSource.getHeartRateDataForWorkout(
          workoutStartTime: record.startTime,
          workoutEndTime: record.endTime,
        ),
        _dataSource.getDistanceDataForWorkout(
          workoutStartTime: record.startTime,
          workoutEndTime: record.endTime,
        ),
        _dataSource.getWorkoutRouteForWorkout(
          workoutId: record.id,
          workoutStartTime: record.startTime,
          workoutEndTime: record.endTime,
        ),
      ];

      final List<dynamic> results = await Future.wait(futures);

      final List<Quantity> heartRateQuantities = results[0] as List<Quantity>;
      final List<Quantity> distanceQuantities = results[1] as List<Quantity>;
      final List<WorkoutRoute> routes = results[2] as List<WorkoutRoute>;

      final List<HeartRateData> heartRateData =
          AppleHealthKitMapper.toHeartRateDataList(heartRateQuantities);
      final List<DistanceData> distanceData =
          AppleHealthKitMapper.toDistanceDataList(distanceQuantities);
      final List<LocationData> locationData =
          AppleHealthKitMapper.toLocationDataList(routes);

      record = record.copyWith(
        heartRateData: heartRateData,
        distanceData: distanceData,
        locationData: locationData,
      );

      enrichedWorkouts.add(record);
    }

    return enrichedWorkouts;
  }
}
