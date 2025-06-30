import 'package:ridingmate/features/activity_history/domain/entities/distance_data.dart';
import 'package:ridingmate/features/activity_history/domain/entities/heart_rate_data.dart';

import '../entities/cycling_workout_record.dart';

abstract class CyclingWorkoutRepository {
  Future<bool> requestPermissions();
  Future<bool> hasPermissions();

  Future<List<CyclingWorkoutRecord>> getCyclingWorkouts({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<CyclingWorkoutRecord> getCyclingWorkoutById(String id);

  Future<List<HeartRateData>> getHeartRateDataForWorkout({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  });

  Future<List<DistanceData>> getDistanceDataForWorkout({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  });
}
