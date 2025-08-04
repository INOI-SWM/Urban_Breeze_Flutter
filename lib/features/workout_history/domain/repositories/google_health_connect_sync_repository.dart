import '../entities/workout_record.dart';

abstract class GoogleHealthConnectSyncRepository {
  Future<bool> requestPermissions();
  Future<bool> hasPermissions();

  Future<List<WorkoutRecord>> fetchCyclingWorkoutsFromHealthConnect({
    DateTime? startDate,
    DateTime? endDate,
  });
}
