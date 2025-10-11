import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/application/use_cases/delete_provider_use_case.dart';
import 'package:urban_breeze/features/integration/application/use_cases/get_integration_status_use_case.dart';
import 'package:urban_breeze/features/integration/di/integration_providers.dart';
import 'package:urban_breeze/features/integration/domain/enums/health_provider.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/connect_apple_health_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/sync_apple_health_kit_data_use_case.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

/// 동기화 화면 상태 관리
class SyncScreenNotifier extends StateNotifier<SyncScreenState>
    with ErrorDisplayMixin {
  SyncScreenNotifier(this.ref, this.context) : super(const SyncScreenState());

  final Ref ref;
  final BuildContext? context;

  /// 연동 상태 확인
  Future<void> checkIntegrationStatus() async {
    try {
      final GetIntegrationStatusUseCase getIntegrationStatusUseCase = ref.read(
        getIntegrationStatusUseCaseProvider,
      );
      final AppResult<Map<HealthProvider, bool>> result =
          await getIntegrationStatusUseCase.execute();

      if (result.isSuccess) {
        AmplitudeAnalytics.logEvent(
          'workout_sync_status_checked',
          properties: <String, dynamic>{
            'connected_services':
                result.dataOrNull!.entries
                    .where(
                      (MapEntry<HealthProvider, bool> entry) => entry.value,
                    )
                    .map(
                      (MapEntry<HealthProvider, bool> entry) =>
                          entry.key.displayName,
                    )
                    .toList(),
          },
        );
        state = state.copyWith(connectionStatus: result.dataOrNull!);
      } else {
        AmplitudeAnalytics.logEvent(
          'workout_sync_status_check_failed',
          properties: <String, dynamic>{
            'error_message': result.exceptionOrNull?.message ?? 'Unknown error',
          },
        );
        debugPrint('연동 상태 확인 실패: ${result.exceptionOrNull}');
      }
    } catch (e) {
      AmplitudeAnalytics.logEvent(
        'workout_sync_status_check_exception',
        properties: <String, dynamic>{'error_message': e.toString()},
      );
      debugPrint('연동 상태 확인 실패: $e');
    }
  }

  /// Apple Health Kit 연동
  Future<void> connectAppleHealth() async {
    setServiceLoading(HealthProvider.appleHealthKit, true);

    try {
      // 1. Apple Health Kit 권한 요청
      final SyncAppleHealthKitDataUseCase syncAppleHealthKitDataUseCase = ref
          .read(syncAppleHealthKitDataUseCaseProvider);

      // 권한 확인
      final bool hasPermission =
          await syncAppleHealthKitDataUseCase.checkPermissions();

      if (!hasPermission) {
        // 권한 요청
        final bool permissionGranted =
            await syncAppleHealthKitDataUseCase.requestPermissions();
        if (!permissionGranted) {
          AmplitudeAnalytics.logEvent(
            'apple_health_kit_permission_denied',
            properties: <String, dynamic>{'source': 'sync_screen'},
          );
          // 권한 거부 시 상태 업데이트
          setServiceLoading(HealthProvider.appleHealthKit, false);
          state = state.copyWith(
            lastDisconnectResult: const DisconnectResult(
              isSuccess: false,
              serviceName: 'Apple Health Kit',
              errorMessage: 'Apple Health Kit 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.',
            ),
          );
          return;
        }
      }

      // 2. 서버에 연동 알림
      final ConnectAppleHealthUseCase connectAppleHealthUseCase = ref.read(
        connectAppleHealthUseCaseProvider,
      );
      final AppResult<void> result = await connectAppleHealthUseCase.execute();

      if (result.isSuccess) {
        AmplitudeAnalytics.logEvent(
          'workout_sync_apple_health_success',
          properties: <String, dynamic>{'sync_method': 'direct'},
        );

        await Future<void>.delayed(const Duration(seconds: 2));

        // 연동 상태 다시 확인
        await checkIntegrationStatus();
      } else {
        AmplitudeAnalytics.logEvent(
          'workout_sync_apple_health_failed',
          properties: <String, dynamic>{
            'error_message': result.exceptionOrNull?.message ?? 'Unknown error',
          },
        );
      }
    } catch (e) {
      AmplitudeAnalytics.logEvent(
        'workout_sync_apple_health_exception',
        properties: <String, dynamic>{'error_message': e.toString()},
      );
    } finally {
      setServiceLoading(HealthProvider.appleHealthKit, false);
    }
  }

  /// 서비스 연동 해제
  Future<void> disconnectService(String serviceName) async {
    state = state.copyWith(isLoading: true);

    try {
      final DeleteProviderUseCase deleteProviderUseCase = ref.read(
        deleteProviderUseCaseProvider,
      );

      // 서비스명을 API에서 사용하는 providerName으로 변환
      final String providerName = _getProviderName(serviceName);
      final AppResult<void> result = await deleteProviderUseCase.execute(
        providerName,
      );

      if (result.isSuccess) {
        AmplitudeAnalytics.logEvent(
          'provider_disconnect_success',
          properties: <String, dynamic>{'provider_name': providerName},
        );
        // 성공 결과 저장
        state = state.copyWith(
          lastDisconnectResult: DisconnectResult(
            isSuccess: true,
            serviceName: serviceName,
          ),
        );
        // 연동 상태 다시 확인
        await checkIntegrationStatus();
      } else {
        AmplitudeAnalytics.logEvent(
          'provider_disconnect_failed',
          properties: <String, dynamic>{
            'provider_name': providerName,
            'error_message': result.exceptionOrNull?.message ?? 'Unknown error',
          },
        );
        // 실패 결과 저장
        state = state.copyWith(
          lastDisconnectResult: DisconnectResult(
            isSuccess: false,
            serviceName: serviceName,
            errorMessage: result.exceptionOrNull?.message ?? 'Unknown error',
          ),
        );
      }
    } catch (e) {
      AmplitudeAnalytics.logEvent(
        'provider_disconnect_exception',
        properties: <String, dynamic>{
          'provider_name': serviceName,
          'error_message': e.toString(),
        },
      );
      // 예외 결과 저장
      state = state.copyWith(
        lastDisconnectResult: DisconnectResult(
          isSuccess: false,
          serviceName: serviceName,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 연동 해제 결과 초기화
  void clearDisconnectResult() {
    state = state.copyWith(lastDisconnectResult: null);
  }

  /// 로딩 상태 설정 (전체)
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// 서비스별 로딩 상태 설정
  void setServiceLoading(HealthProvider provider, bool isLoading) {
    final Map<HealthProvider, bool> newLoadingStatus =
        Map<HealthProvider, bool>.from(state.loadingStatus);
    newLoadingStatus[provider] = isLoading;

    // 전체 로딩 상태도 업데이트 (하나라도 로딩 중이면 true)
    final bool hasAnyLoading = newLoadingStatus.values.any(
      (bool loading) => loading,
    );

    state = state.copyWith(
      loadingStatus: newLoadingStatus,
      isLoading: hasAnyLoading,
    );
  }

  /// 서비스명을 API providerName으로 변환
  String _getProviderName(String serviceName) {
    for (final HealthProvider provider in HealthProvider.values) {
      if (provider.serviceName == serviceName) {
        return provider.apiProviderName;
      }
    }
    return serviceName;
  }
}

/// 동기화 화면 상태
class SyncScreenState {
  const SyncScreenState({
    this.isLoading = false,
    this.connectionStatus = const <HealthProvider, bool>{},
    this.loadingStatus = const <HealthProvider, bool>{},
    this.lastDisconnectResult,
  });

  final bool isLoading;
  final Map<HealthProvider, bool> connectionStatus;
  final Map<HealthProvider, bool> loadingStatus; // 서비스별 로딩 상태
  final DisconnectResult? lastDisconnectResult;

  SyncScreenState copyWith({
    bool? isLoading,
    Map<HealthProvider, bool>? connectionStatus,
    Map<HealthProvider, bool>? loadingStatus,
    DisconnectResult? lastDisconnectResult,
  }) {
    return SyncScreenState(
      isLoading: isLoading ?? this.isLoading,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      lastDisconnectResult: lastDisconnectResult ?? this.lastDisconnectResult,
    );
  }
}

/// 연동 해제 결과
class DisconnectResult {
  const DisconnectResult({
    required this.isSuccess,
    required this.serviceName,
    this.errorMessage,
  });

  final bool isSuccess;
  final String serviceName;
  final String? errorMessage;
}
