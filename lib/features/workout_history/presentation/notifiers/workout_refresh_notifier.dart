import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/features/integration/domain/entities/sync_status.dart';
import 'package:urban_breeze/features/workout_history/application/facades/workout_refresh_facade.dart';
import 'package:urban_breeze/features/workout_history/application/facades/workout_refresh_polling_facade.dart';

/// 운동 기록 새로고침 상태 관리
class WorkoutRefreshNotifier extends StateNotifier<WorkoutRefreshState> {
  WorkoutRefreshNotifier(
    WorkoutRefreshFacade workoutRefreshFacade,
    this._workoutRefreshPollingFacade,
  ) : super(const WorkoutRefreshState());

  final WorkoutRefreshPollingFacade _workoutRefreshPollingFacade;

  StreamSubscription<SyncPollingState>? _pollingSubscription;

  /// 새로고침 수행 (폴링 방식)
  Future<void> performRefresh() async {
    if (state.isRefreshing) return; // 이미 새로고침 중이면 중단

    state = state.copyWith(
      isRefreshing: true,
      statusMessage: '연동 상태를 확인하는 중...',
      syncStatus: null,
    );

    try {
      AmplitudeAnalytics.logEvent('workout_refresh_started');

      // 폴링 스트림 구독
      _pollingSubscription?.cancel();
      _pollingSubscription = _workoutRefreshPollingFacade
          .performRefreshWithPolling()
          .listen(
            _handlePollingState,
            onError: _handlePollingError,
            onDone: _handlePollingDone,
          );
    } catch (e) {
      AmplitudeAnalytics.logEvent(
        'workout_refresh_exception',
        properties: <String, dynamic>{'error_message': e.toString()},
      );

      state = state.copyWith(
        isRefreshing: false,
        statusMessage: '새로고침 중 오류가 발생했습니다: $e',
        lastRefreshResult: null,
      );
    }
  }

  /// 폴링 상태 처리
  void _handlePollingState(SyncPollingState pollingState) {
    if (pollingState.errorMessage != null) {
      // 에러 상태
      AmplitudeAnalytics.logEvent(
        'workout_refresh_failed',
        properties: <String, dynamic>{
          'error_message': pollingState.errorMessage,
        },
      );

      state = state.copyWith(
        isRefreshing: false,
        statusMessage: '새로고침 실패: ${pollingState.errorMessage}',
        lastRefreshResult: null,
        syncStatus: pollingState.currentStatus,
      );
      _pollingSubscription?.cancel();
      return;
    }

    if (pollingState.currentStatus == null) {
      // 초기 상태
      state = state.copyWith(isRefreshing: true, statusMessage: '동기화 요청 중...');
      return;
    }

    final SyncStatus syncStatus = pollingState.currentStatus!;

    // 상태에 따라 메시지 업데이트
    String statusMessage = '동기화 중...';

    // 폴링 중일 때 (60초 이내)
    if (pollingState.isPolling) {
      statusMessage = '데이터를 가져오는 중... (${syncStatus.receivedCount}개 수신)';
    }
    // 폴링 완료 (60초 경과 또는 조기 완료)
    else {
      if (syncStatus.receivedCount > 0) {
        statusMessage = '운동 기록 ${syncStatus.receivedCount}개 연동 성공!';

        AmplitudeAnalytics.logEvent(
          'workout_refresh_success',
          properties: <String, dynamic>{
            'received_count': syncStatus.receivedCount,
            'job_id': syncStatus.jobId,
          },
        );
      } else if (syncStatus.isNoActivities) {
        statusMessage = '새로운 운동 기록이 없습니다.';

        AmplitudeAnalytics.logEvent(
          'workout_refresh_no_activities',
          properties: <String, dynamic>{'job_id': syncStatus.jobId},
        );
      } else if (syncStatus.isFailed) {
        statusMessage = '동기화 실패. 다시 시도해주세요.';

        AmplitudeAnalytics.logEvent(
          'workout_refresh_failed',
          properties: <String, dynamic>{
            'job_id': syncStatus.jobId,
            'received_count': syncStatus.receivedCount,
          },
        );
      } else {
        // 완료 상태
        statusMessage = '운동 기록 ${syncStatus.receivedCount}개 연동 성공!';

        AmplitudeAnalytics.logEvent(
          'workout_refresh_success',
          properties: <String, dynamic>{
            'received_count': syncStatus.receivedCount,
            'job_id': syncStatus.jobId,
          },
        );
      }
    }

    state = state.copyWith(
      isRefreshing: pollingState.isPolling,
      statusMessage: statusMessage,
      syncStatus: syncStatus,
    );

    // 완료/실패/기록없음 상태면 구독 취소
    if (!pollingState.isPolling) {
      _pollingSubscription?.cancel();
    }
  }

  /// 폴링 에러 처리
  void _handlePollingError(Object error, StackTrace stackTrace) {
    AmplitudeAnalytics.logEvent(
      'workout_refresh_polling_error',
      properties: <String, dynamic>{'error_message': error.toString()},
    );

    state = state.copyWith(
      isRefreshing: false,
      statusMessage: '동기화 중 오류가 발생했습니다.',
      lastRefreshResult: null,
    );

    _pollingSubscription?.cancel();
  }

  /// 폴링 완료 처리
  void _handlePollingDone() {
    // Stream이 정상적으로 종료되면 자동으로 구독 취소됨
    _pollingSubscription?.cancel();
  }

  @override
  void dispose() {
    _pollingSubscription?.cancel();
    super.dispose();
  }

  /// 새로고침 결과 초기화
  void clearRefreshResult() {
    state = state.copyWith(lastRefreshResult: null);
  }
}

/// 새로고침 상태
class WorkoutRefreshState {
  const WorkoutRefreshState({
    this.isRefreshing = false,
    this.statusMessage = '',
    this.lastRefreshResult,
    this.syncStatus,
  });

  final bool isRefreshing;
  final String statusMessage;
  final WorkoutRefreshResult? lastRefreshResult;
  final SyncStatus? syncStatus;

  WorkoutRefreshState copyWith({
    bool? isRefreshing,
    String? statusMessage,
    WorkoutRefreshResult? lastRefreshResult,
    SyncStatus? syncStatus,
  }) {
    return WorkoutRefreshState(
      isRefreshing: isRefreshing ?? this.isRefreshing,
      statusMessage: statusMessage ?? this.statusMessage,
      lastRefreshResult: lastRefreshResult ?? this.lastRefreshResult,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
