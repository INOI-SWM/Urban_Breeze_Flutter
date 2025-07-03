import '../entities/workout_record.dart';

abstract class HealthKitSyncRepository {
  Future<bool> requestPermissions();
  Future<bool> hasPermissions();

  Future<List<WorkoutRecord>> fetchCyclingWorkoutsFromHealthKit({
    DateTime? startDate,
    DateTime? endDate,
  });
}
