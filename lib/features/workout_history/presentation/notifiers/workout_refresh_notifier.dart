import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/application/facades/workout_refresh_facade.dart';

/// 운동 기록 새로고침 상태 관리
class WorkoutRefreshNotifier extends StateNotifier<WorkoutRefreshState> {
  WorkoutRefreshNotifier(this._workoutRefreshFacade)
    : super(const WorkoutRefreshState());

  final WorkoutRefreshFacade _workoutRefreshFacade;

  /// 새로고침 수행
  Future<void> performRefresh() async {
    if (state.isRefreshing) return; // 이미 새로고침 중이면 중단

    state = state.copyWith(
      isRefreshing: true,
      statusMessage: '연동 상태를 확인하는 중...',
    );

    try {
      AmplitudeAnalytics.logEvent('workout_refresh_started');

      final AppResult<WorkoutRefreshResult> result =
          await _workoutRefreshFacade.performRefresh();

      if (result.isSuccess) {
        final WorkoutRefreshResult refreshResult = result.dataOrNull!;

        AmplitudeAnalytics.logEvent(
          'workout_refresh_success',
          properties: <String, dynamic>{
            'total_workouts': refreshResult.allWorkouts.length,
            'total_success': refreshResult.totalSuccess,
            'total_attempts': refreshResult.totalAttempts,
          },
        );

        state = state.copyWith(
          isRefreshing: false,
          statusMessage: _getStatusMessage(refreshResult),
          lastRefreshResult: refreshResult,
        );
      } else {
        AmplitudeAnalytics.logEvent(
          'workout_refresh_failed',
          properties: <String, dynamic>{
            'error_message': result.exceptionOrNull?.message ?? 'Unknown error',
          },
        );

        state = state.copyWith(
          isRefreshing: false,
          statusMessage:
              '새로고침 실패: ${result.exceptionOrNull?.message ?? 'Unknown error'}',
          lastRefreshResult: null,
        );
      }
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

  /// 새로고침 결과 초기화
  void clearRefreshResult() {
    state = state.copyWith(lastRefreshResult: null);
  }

  /// 상태 메시지 생성
  String _getStatusMessage(WorkoutRefreshResult result) {
    // 연동할 것이 없는 경우 (플랫폼 지원 안함)
    if (result.totalAttempts == 0) {
      return '설정 버튼을 눌러, 동기화 설정을 먼저 해 주세요';
    } else if (result.noPermissionCount == result.totalAttempts &&
        result.totalSuccess == 0) {
      // 모든 서비스에 권한이 없는 경우
      return '오른쪽 설정버튼 클릭후 동기화 설정해주세요';
    } else {
      // 성공/실패 개수 기반 메시지
      if (result.totalSuccess == 0) {
        return '동기화할 수 있는 데이터가 없습니다.';
      } else {
        return '데이터 동기화 완료!';
      }
    }
  }
}

/// 새로고침 상태
class WorkoutRefreshState {
  const WorkoutRefreshState({
    this.isRefreshing = false,
    this.statusMessage = '',
    this.lastRefreshResult,
  });

  final bool isRefreshing;
  final String statusMessage;
  final WorkoutRefreshResult? lastRefreshResult;

  WorkoutRefreshState copyWith({
    bool? isRefreshing,
    String? statusMessage,
    WorkoutRefreshResult? lastRefreshResult,
  }) {
    return WorkoutRefreshState(
      isRefreshing: isRefreshing ?? this.isRefreshing,
      statusMessage: statusMessage ?? this.statusMessage,
      lastRefreshResult: lastRefreshResult ?? this.lastRefreshResult,
    );
  }
}
