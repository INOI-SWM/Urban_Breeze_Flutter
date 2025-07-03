import '../../domain/entities/workout_record.dart';
import '../../domain/repositories/health_kit_sync_repository.dart';

class SyncAppleHealthKitDataUseCase {
  const SyncAppleHealthKitDataUseCase(this._repository);
  final HealthKitSyncRepository _repository;

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
    //TODO: 서버 저장
    return completeData;
  }
}
