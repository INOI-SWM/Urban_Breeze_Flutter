import 'dart:io';

import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/application/use_cases/get_integration_status_use_case.dart';
import 'package:urban_breeze/features/integration/domain/entities/api_usage.dart';
import 'package:urban_breeze/features/integration/domain/enums/health_provider.dart';
import 'package:urban_breeze/features/workout_history/application/facades/workout_sync_facade.dart';

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
      final AppResult<ApiUsage> usageResult =
          await _getIntegrationStatusUseCase.executeWithApiUsage();

      if (!usageResult.isSuccess) {
        return AppFailure<Map<String, dynamic>?>(usageResult.exceptionOrNull!);
      }

      final ApiUsage apiUsage = usageResult.dataOrNull!;

      if (apiUsage.remainingUsage <= 0 || apiUsage.isExceeded) {
        return const AppFailure<Map<String, dynamic>?>(
          NetworkException('이번 달 동기화 가능 횟수를 모두 사용했습니다.\n다음 달에 다시 시도해주세요.'),
        );
      }

      final AppResult<Map<HealthProvider, DateTime>> integrationResult =
          await _getIntegrationStatusUseCase.executeWithLastSync();

      if (!integrationResult.isSuccess) {
        return AppFailure<Map<String, dynamic>?>(
          integrationResult.exceptionOrNull!,
        );
      }

      final Map<HealthProvider, DateTime> lastSyncTimes =
          integrationResult.dataOrNull!;

      if (lastSyncTimes.isEmpty) {
        return const AppFailure<Map<String, dynamic>?>(
          NetworkException('연동된 서비스가 없습니다. \n 설정에서 서비스를 연동해주세요.'),
        );
      }

      return await _performSelectiveSync(lastSyncTimes);
    } catch (e) {
      return AppFailure<Map<String, dynamic>?>(
        NetworkException('동기화 중 오류가 발생했습니다: $e'),
      );
    }
  }

  /// 연동된 서비스에 따라 선택적 동기화 수행
  Future<AppResult<Map<String, dynamic>?>> _performSelectiveSync(
    Map<HealthProvider, DateTime> lastSyncTimes,
  ) async {
    final bool hasRemoteIntegration = lastSyncTimes.keys.any(
      (HealthProvider provider) =>
          provider != HealthProvider.appleHealthKit &&
          provider != HealthProvider.samsungHealth &&
          provider != HealthProvider.healthConnect,
    );

    // iOS에서만 Apple HealthKit 동기화
    if (Platform.isIOS &&
        lastSyncTimes.containsKey(HealthProvider.appleHealthKit)) {
      final DateTime lastSyncAt = lastSyncTimes[HealthProvider.appleHealthKit]!;
      final AppResult<Map<String, dynamic>?> result = await _workoutSyncFacade
          .syncAppleHealthData(startDate: lastSyncAt, endDate: DateTime.now());

      if (result.isSuccess && result.dataOrNull != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          result.dataOrNull!,
        );
        data['hasRemoteIntegration'] = hasRemoteIntegration;
        return AppSuccess<Map<String, dynamic>?>(data);
      }

      return result;
    }

    // Android에서 Samsung Health 및/또는 Google Health Connect 동기화
    if (Platform.isAndroid) {
      int totalSuccess = 0;
      final List<Map<String, dynamic>> allWorkouts = <Map<String, dynamic>>[];

      // 1. Samsung Health 동기화
      if (lastSyncTimes.containsKey(HealthProvider.samsungHealth)) {
        final DateTime lastSyncAt =
            lastSyncTimes[HealthProvider.samsungHealth]!;
        final AppResult<Map<String, dynamic>?> result = await _workoutSyncFacade
            .fetchSamsungHealthData(
              startDate: lastSyncAt,
              endDate: DateTime.now(),
            );

        if (result.isSuccess && result.dataOrNull != null) {
          totalSuccess++;
          allWorkouts.add(result.dataOrNull!);
        }
      }

      // 2. Google Health Connect 동기화
      if (lastSyncTimes.containsKey(HealthProvider.healthConnect)) {
        final DateTime lastSyncAt =
            lastSyncTimes[HealthProvider.healthConnect]!;
        final AppResult<Map<String, dynamic>?> result = await _workoutSyncFacade
            .fetchHealthConnectData(
              startDate: lastSyncAt,
              endDate: DateTime.now(),
            );

        if (result.isSuccess && result.dataOrNull != null) {
          totalSuccess++;
          allWorkouts.add(result.dataOrNull!);
        }
      }

      // 하나라도 성공했으면 결과 반환
      if (totalSuccess > 0) {
        return AppSuccess<Map<String, dynamic>?>(<String, dynamic>{
          'hasRemoteIntegration': hasRemoteIntegration,
          'totalSuccess': totalSuccess,
          'allWorkouts': allWorkouts,
        });
      }
    }

    // 원격 연동만 있는 경우 또는 플랫폼과 맞지 않는 경우
    if (hasRemoteIntegration) {
      // 원격 동기화만 수행 (Apple HealthKit/Samsung/Google Health 없이)
      return const AppSuccess<Map<String, dynamic>?>(<String, dynamic>{
        'hasRemoteIntegration': true,
        'totalSuccess': 0,
      });
    }

    return await _workoutSyncFacade.performFullSync();
  }
}
