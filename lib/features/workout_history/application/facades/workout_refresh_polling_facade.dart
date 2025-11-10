import 'dart:async';

import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/application/use_cases/poll_sync_status_use_case.dart';
import 'package:urban_breeze/features/integration/domain/entities/sync_status.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/selective_sync_use_case.dart';

/// 운동 기록 새로고침 + 폴링 Facade
/// 초기 동기화 요청 후 5초 간격으로 상태를 폴링
class WorkoutRefreshPollingFacade {
  const WorkoutRefreshPollingFacade({
    required this.selectiveSyncUseCase,
    required this.pollSyncStatusUseCase,
  });

  final SelectiveSyncUseCase selectiveSyncUseCase;
  final PollSyncStatusUseCase pollSyncStatusUseCase;

  /// 폴링 간격 (5초)
  static const Duration pollingInterval = Duration(seconds: 5);

  /// 최대 폴링 시간 (3분)
  static const Duration maxPollingDuration = Duration(minutes: 3);

  /// 새로고침 + 폴링 수행
  /// Stream을 반환하여 UI에서 실시간 상태를 구독할 수 있도록 함
  Stream<SyncPollingState> performRefreshWithPolling() async* {
    // 1. 초기 동기화 요청
    yield const SyncPollingState(isPolling: true);

    final AppResult<Map<String, dynamic>?> initialSyncResult =
        await selectiveSyncUseCase.execute();

    if (!initialSyncResult.isSuccess) {
      yield SyncPollingState(
        isPolling: false,
        errorMessage: initialSyncResult.exceptionOrNull?.message ?? '동기화 요청 실패',
      );
      return;
    }

    final Map<String, dynamic>? syncData = initialSyncResult.dataOrNull;

    // Apple HealthKit 전용 동기화 판단:
    // 1. source가 'apple_health_kit'이고
    // 2. hasRemoteIntegration이 false인 경우
    // → 로컬 동기화만 했으므로 폴링 불필요
    final bool isAppleHealthKitOnly =
        syncData != null && syncData['source'] == 'apple_health_kit';

    final bool hasRemoteIntegration =
        syncData != null &&
        (syncData['hasRemoteIntegration'] as bool? ?? false);

    if (isAppleHealthKitOnly && !hasRemoteIntegration) {
      // 로컬 동기화만 있는 경우 즉시 완료
      yield SyncPollingState(
        isPolling: false,
        currentStatus: SyncStatus(
          jobId: 0,
          status: SyncStatusType.completed,
          startDate: '',
          endDate: '',
          receivedCount: syncData['totalSuccess'] as int? ?? 0,
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        ),
      );
      return;
    }

    // 2. 5초 간격으로 상태 폴링 (Terra/Integration API 원격 동기화)
    final DateTime startTime = DateTime.now();

    while (true) {
      await Future<void>.delayed(pollingInterval);

      // 타임아웃 체크 (최대 3분)
      final Duration elapsed = DateTime.now().difference(startTime);
      if (elapsed > maxPollingDuration) {
        // 3분 초과 시 타임아웃으로 종료
        yield SyncPollingState(
          isPolling: false,
          currentStatus: SyncStatus(
            jobId: 0,
            status: SyncStatusType.noActivities,
            startDate: '',
            endDate: '',
            receivedCount: 0,
            createdAt: DateTime.now(),
            completedAt: DateTime.now(),
          ),
        );
        return;
      }

      final AppResult<SyncStatus> statusResult =
          await pollSyncStatusUseCase.execute();

      if (!statusResult.isSuccess) {
        // 404 에러(작업 없음)는 아직 작업이 시작 안된 것일 수 있으므로 계속 폴링
        if (statusResult.exceptionOrNull is SyncJobNotFoundException) {
          continue;
        }
        yield SyncPollingState(
          isPolling: false,
          errorMessage: statusResult.exceptionOrNull?.message ?? '상태 조회 실패',
        );
        return;
      }

      final SyncStatus currentStatus = statusResult.dataOrNull!;
      yield SyncPollingState(
        isPolling: currentStatus.isInProgress,
        currentStatus: currentStatus,
      );

      // 완료, 실패, 기록 없음 상태면 폴링 종료
      if (currentStatus.isCompleted ||
          currentStatus.isFailed ||
          currentStatus.isNoActivities) {
        return;
      }
    }
  }
}

/// 동기화 폴링 상태
class SyncPollingState {
  const SyncPollingState({
    this.isPolling = false,
    this.currentStatus,
    this.errorMessage,
  });

  final bool isPolling;
  final SyncStatus? currentStatus;
  final String? errorMessage;

  SyncPollingState copyWith({
    bool? isPolling,
    SyncStatus? currentStatus,
    String? errorMessage,
  }) {
    return SyncPollingState(
      isPolling: isPolling ?? this.isPolling,
      currentStatus: currentStatus ?? this.currentStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
