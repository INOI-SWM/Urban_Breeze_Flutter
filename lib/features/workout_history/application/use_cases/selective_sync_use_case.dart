import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/application/facades/workout_sync_facade.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/get_integration_status_use_case.dart';
import 'package:urban_breeze/features/workout_history/domain/enums/health_provider.dart';

/// 선택적 동기화 Use Case
/// 연동된 서비스에 따라 적절한 동기화 방법을 선택하여 수행
class SelectiveSyncUseCase {
  const SelectiveSyncUseCase(
    this._getIntegrationStatusUseCase,
    this._workoutSyncFacade,
  );

  final GetIntegrationStatusUseCase _getIntegrationStatusUseCase;
  final WorkoutSyncFacade _workoutSyncFacade;

  /// 연동 상태를 확인하고 선택적 동기화 수행
  Future<AppResult<Map<String, dynamic>?>> execute() async {
    try {
      // 1. 연동 상태와 마지막 동기화 시간 확인
      final AppResult<Map<HealthProvider, DateTime?>> integrationResult =
          await _getIntegrationStatusUseCase.executeWithLastSync();

      if (!integrationResult.isSuccess) {
        return AppFailure<Map<String, dynamic>?>(
          integrationResult.exceptionOrNull!,
        );
      }

      final Map<HealthProvider, DateTime?> connectionStatus =
          integrationResult.dataOrNull!;

      // 2. 연동된 서비스 필터링
      final List<HealthProvider> connectedServices =
          connectionStatus.entries
              .where(
                (MapEntry<HealthProvider, DateTime?> entry) =>
                    entry.value != null,
              )
              .map((MapEntry<HealthProvider, DateTime?> entry) => entry.key)
              .toList();

      if (connectedServices.isEmpty) {
        return const AppFailure<Map<String, dynamic>?>(
          NetworkException('연동된 서비스가 없습니다. \n 설정에서 서비스를 연동해주세요.'),
        );
      }

      // 3. 선택적 동기화 수행 (마지막 동기화 시간 포함)
      return await _performSelectiveSync(connectedServices, connectionStatus);
    } catch (e) {
      return AppFailure<Map<String, dynamic>?>(
        NetworkException('동기화 중 오류가 발생했습니다: $e'),
      );
    }
  }

  /// 연동된 서비스에 따라 선택적 동기화 수행
  Future<AppResult<Map<String, dynamic>?>> _performSelectiveSync(
    List<HealthProvider> connectedServices,
    Map<HealthProvider, DateTime?> lastSyncTimes,
  ) async {
    // Apple Health Kit이 연동된 경우
    if (connectedServices.contains(HealthProvider.appleHealthKit)) {
      final DateTime? lastSyncAt = lastSyncTimes[HealthProvider.appleHealthKit];
      return await _workoutSyncFacade.syncAppleHealthData(
        startDate: lastSyncAt,
        endDate: DateTime.now(),
      );
    }

    // Samsung Health가 연동된 경우
    if (connectedServices.contains(HealthProvider.samsungHealth)) {
      final DateTime? lastSyncAt = lastSyncTimes[HealthProvider.samsungHealth];
      return await _workoutSyncFacade.syncSamsungHealthData(
        startDate: lastSyncAt,
        endDate: DateTime.now(),
      );
    }

    // Health Connect가 연동된 경우
    if (connectedServices.contains(HealthProvider.healthConnect)) {
      final DateTime? lastSyncAt = lastSyncTimes[HealthProvider.healthConnect];
      return await _workoutSyncFacade.syncHealthConnectData(
        startDate: lastSyncAt,
        endDate: DateTime.now(),
      );
    }

    // 기본적으로 전체 동기화 수행
    return await _workoutSyncFacade.performFullSync();
  }
}
