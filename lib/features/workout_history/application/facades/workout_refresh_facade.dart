import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/selective_sync_use_case.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_record.dart';

/// 운동 기록 새로고침 Facade
/// 새로고침 관련 비즈니스 로직을 통합 관리
class WorkoutRefreshFacade {
  const WorkoutRefreshFacade(this._selectiveSyncUseCase);

  final SelectiveSyncUseCase _selectiveSyncUseCase;

  /// 연동 상태에 따른 선택적 새로고침 수행
  Future<AppResult<WorkoutRefreshResult>> performRefresh() async {
    try {
      final AppResult<Map<String, dynamic>?> syncResult =
          await _selectiveSyncUseCase.execute();

      if (!syncResult.isSuccess) {
        return AppFailure<WorkoutRefreshResult>(syncResult.exceptionOrNull!);
      }

      final Map<String, dynamic>? data = syncResult.dataOrNull;
      if (data == null) {
        return const AppFailure<WorkoutRefreshResult>(
          NetworkException('동기화 데이터를 받을 수 없습니다.'),
        );
      }

      // 동기화 결과 파싱
      final List<WorkoutRecord> allWorkouts =
          data['allWorkouts'] as List<WorkoutRecord>;
      final int totalSuccess = data['totalSuccess'] as int;
      final int totalAttempts = data['totalAttempts'] as int;
      final int noPermissionCount = data['noPermissionCount'] as int;

      return AppSuccess<WorkoutRefreshResult>(
        WorkoutRefreshResult(
          allWorkouts: allWorkouts,
          totalSuccess: totalSuccess,
          totalAttempts: totalAttempts,
          noPermissionCount: noPermissionCount,
        ),
      );
    } catch (e) {
      return AppFailure<WorkoutRefreshResult>(
        NetworkException('새로고침 중 오류가 발생했습니다: $e'),
      );
    }
  }
}

/// 새로고침 결과
class WorkoutRefreshResult {
  const WorkoutRefreshResult({
    required this.allWorkouts,
    required this.totalSuccess,
    required this.totalAttempts,
    required this.noPermissionCount,
  });

  final List<WorkoutRecord> allWorkouts;
  final int totalSuccess;
  final int totalAttempts;
  final int noPermissionCount;
}
