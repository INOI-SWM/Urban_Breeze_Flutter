import 'dart:async';

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

    // 2. 5초 간격으로 상태 폴링
    while (true) {
      await Future<void>.delayed(pollingInterval);

      final AppResult<SyncStatus> statusResult =
          await pollSyncStatusUseCase.execute();

      if (!statusResult.isSuccess) {
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
