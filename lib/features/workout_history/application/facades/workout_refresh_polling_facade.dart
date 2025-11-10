import 'dart:async';

import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/application/use_cases/get_integration_activity_use_case.dart';
import 'package:urban_breeze/features/integration/application/use_cases/poll_sync_status_use_case.dart';
import 'package:urban_breeze/features/integration/domain/entities/sync_status.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/selective_sync_use_case.dart';

/// 운동 기록 새로고침 + 폴링 Facade
class WorkoutRefreshPollingFacade {
  const WorkoutRefreshPollingFacade({
    required this.selectiveSyncUseCase,
    required this.pollSyncStatusUseCase,
    required this.getIntegrationActivityUseCase,
  });

  final SelectiveSyncUseCase selectiveSyncUseCase;
  final PollSyncStatusUseCase pollSyncStatusUseCase;
  final GetIntegrationActivityUseCase getIntegrationActivityUseCase;

  static const Duration firstPollingDelay = Duration(seconds: 10);
  static const Duration pollingInterval = Duration(seconds: 5);
  static const Duration maxPollingDuration = Duration(seconds: 70);
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

    final bool isAppleHealthKitOnly =
        syncData != null && syncData['source'] == 'apple_health_kit';

    final bool hasRemoteIntegration =
        syncData != null &&
        (syncData['hasRemoteIntegration'] as bool? ?? false);

    if (isAppleHealthKitOnly && !hasRemoteIntegration) {
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

    // 2. Terra 동기화 시작 요청
    await getIntegrationActivityUseCase.execute();

    // 3. 상태 폴링
    final DateTime startTime = DateTime.now();
    int pollCount = 0;
    SyncStatus? lastStatus;

    while (true) {
      final Duration delay =
          pollCount == 0 ? firstPollingDelay : pollingInterval;
      await Future<void>.delayed(delay);
      pollCount++;

      final Duration elapsed = DateTime.now().difference(startTime);

      if (elapsed > maxPollingDuration) {
        final SyncStatus finalStatus =
            lastStatus ??
            SyncStatus(
              jobId: 0,
              status: SyncStatusType.noActivities,
              startDate: '',
              endDate: '',
              receivedCount: 0,
              createdAt: DateTime.now(),
              completedAt: DateTime.now(),
            );

        yield SyncPollingState(isPolling: false, currentStatus: finalStatus);
        return;
      }

      final AppResult<SyncStatus> statusResult =
          await pollSyncStatusUseCase.execute();

      if (!statusResult.isSuccess) {
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
      lastStatus = currentStatus;

      if (currentStatus.isCompleted) {
        yield SyncPollingState(isPolling: false, currentStatus: currentStatus);
        return;
      }

      yield SyncPollingState(isPolling: true, currentStatus: currentStatus);
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
