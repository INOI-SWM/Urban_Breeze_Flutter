import '../../domain/entities/workout_record.dart';
import '../../domain/repositories/google_health_connect_sync_repository.dart';

class SyncGoogleHealthConnectDataUseCase {
  const SyncGoogleHealthConnectDataUseCase(this._repository);
  final GoogleHealthConnectSyncRepository _repository;

  Future<bool> requestPermissions() async {
    return await _repository.requestPermissions();
  }

  Future<bool> checkPermissions() async {
    return await _repository.hasPermissions();
  }

  /// 전체 운동 데이터 동기화 (운동 + 상세 데이터)
  Future<Map<WorkoutRecord, Map<String, dynamic>>> syncCompleteWorkoutData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final Map<WorkoutRecord, Map<String, dynamic>> completeData =
        <WorkoutRecord, Map<String, dynamic>>{};

    try {
      final List<WorkoutRecord> workouts = await _repository
          .fetchCyclingWorkoutsFromHealthConnect(
            startDate: startDate,
            endDate: endDate,
          );

      for (final WorkoutRecord workout in workouts) {
        completeData[workout] = <String, dynamic>{
          'heartRateData': workout.heartRateData,
          'distanceData': workout.distanceData,
          'locationData': workout.locationData,
        };
      }
    } catch (e) {
      rethrow;
    }

    return completeData;
  }

  /// 운동 기록만 조회 (상세 데이터 없이)
  Future<List<WorkoutRecord>> fetchBasicWorkoutData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _repository.fetchCyclingWorkoutsFromHealthConnect(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }
}
