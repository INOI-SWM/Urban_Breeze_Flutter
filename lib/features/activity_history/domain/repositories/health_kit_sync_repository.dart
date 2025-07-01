import '../entities/cycling_workout_record.dart';

abstract class HealthKitSyncRepository {
  Future<bool> requestPermissions();
  Future<bool> hasPermissions();

  Future<List<CyclingWorkoutRecord>> fetchCyclingWorkoutsFromHealthKit({
    DateTime? startDate,
    DateTime? endDate,
  });
}
