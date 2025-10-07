import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/core/services/deep_link_service.dart';
import 'package:urban_breeze/features/integration/domain/entities/integration_auth.dart';
import 'package:urban_breeze/features/workout_history/application/facades/workout_sync_facade.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';
import 'package:urban_breeze/features/workout_history/domain/enums/health_provider.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';
import 'package:urban_breeze/features/workout_history/presentation/notifiers/sync_screen_notifier.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_outlined.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_solid.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:urban_breeze/shared/design_system/widgets/modal/modal_show.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';
import 'package:urban_breeze/shared/utils/webview_navigation.dart';

class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen>
    with ErrorDisplayMixin {
  StreamSubscription<IntegrationCallback>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    // 화면 조회 이벤트
    AmplitudeAnalytics.logScreenView('workout_sync_screen');

    // Deep Link 콜백 리스너 등록
    _deepLinkSubscription = DeepLinkService().callbackStream.listen(
      _handleIntegrationCallback,
    );

    // 연동 상태 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncScreenNotifierProvider.notifier).checkIntegrationStatus();
    });
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  /// Deep Link 콜백 처리
  void _handleIntegrationCallback(IntegrationCallback callback) {
    debugPrint('연동 콜백 수신: $callback');
    // 연동 상태 다시 확인
    ref.read(syncScreenNotifierProvider.notifier).checkIntegrationStatus();
  }

  /// 공통 헬스 데이터 동기화 메서드
  Future<void> _syncHealthData({
    required String serviceName,
    required String buttonEvent,
    required String successEvent,
    required String failedEvent,
    required Future<AppResult<Map<String, dynamic>?>> Function() syncMethod,
  }) async {
    AmplitudeAnalytics.logButtonClick(buttonEvent);

    setState(() {
      // 로딩 상태는 notifier에서 관리
    });

    final AppResult<Map<String, dynamic>?> result = await syncMethod();

    if (result.isSuccess) {
      AmplitudeAnalytics.logEvent(
        successEvent,
        properties: <String, dynamic>{'sync_method': 'direct'},
      );
      if (mounted) {
        showSuccessMessage(context, '$serviceName 데이터가 동기화되었습니다.');
      }
    } else {
      // 실패 시 예외 타입에 따라 다른 메시지 표시
      final String errorMessage =
          result.exceptionOrNull?.message ?? 'Unknown error';

      AmplitudeAnalytics.logEvent(
        failedEvent,
        properties: <String, dynamic>{'error_message': errorMessage},
      );

      if (mounted) {
        // iOS에서 Health Connect나 Samsung Health 사용 시 지원하지 않는 플랫폼 메시지 표시
        if (result.exceptionOrNull is PlatformException ||
            result.exceptionOrNull is TerraApiException) {
          showErrorMessage(context, '지원하지 않는 플랫폼입니다');
        } else {
          showErrorMessage(context, '$serviceName 데이터 가져오기 실패: $errorMessage');
        }
      }
    }
  }

  /// 연동 해제 확인 모달 표시
  Future<void> _showDisconnectModal(String serviceName) async {
    AmplitudeAnalytics.logEvent(
      'workout_sync_disconnect_modal_shown',
      properties: <String, dynamic>{'service_name': serviceName},
    );

    await ModalShow.show(
      context: context,
      title: '연동 해제',
      content: Text('$serviceName 연동을 해제하시겠습니까?'),
      primaryButtonText: '해제',
      secondaryButtonText: '취소',
      onPrimaryButtonPressed: () {
        AmplitudeAnalytics.logEvent(
          'workout_sync_disconnect_confirmed',
          properties: <String, dynamic>{'service_name': serviceName},
        );
        ref
            .read(syncScreenNotifierProvider.notifier)
            .disconnectService(serviceName);
      },
      onSecondaryButtonPressed: () {
        AmplitudeAnalytics.logEvent(
          'workout_sync_disconnect_cancelled',
          properties: <String, dynamic>{'service_name': serviceName},
        );
        // 취소 버튼 - 아무것도 하지 않음 (모달은 자동으로 닫힘)
      },
    );
  }

  /// Apple Health Kit 동기화
  Future<void> _syncAppleHealthKit() async {
    AmplitudeAnalytics.logButtonClick('workout_sync_apple_health');

    // 권한 요청 전 안내 모달 표시
    await _showHealthKitPermissionInfoDialog();
  }

  /// HealthKit 권한 안내 다이얼로그 표시
  Future<void> _showHealthKitPermissionInfoDialog() async {
    final SemanticColors colors = context.semanticColor;

    await ModalShow.show<void>(
      context: context,
      title: 'Apple Health 연동',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                'Urban Breeze는 Apple HealthKit을 통해\n다음 데이터를 읽어옵니다',
                style: AppTextStyles.body2.normalBold.copyWith(
                  color: colors.labelStrong,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _buildPermissionItem('🚴 사이클링 운동 기록'),
            _buildPermissionItem('❤️ 심박수 데이터'),
            _buildPermissionItem('📍 이동 거리'),
            _buildPermissionItem('🔥 소모 칼로리'),
            _buildPermissionItem('🗺️ GPS 경로 데이터'),
            const SizedBox(height: 12),
            Text(
              '수집된 데이터는 운동 기록 관리, 성과 추적, 개인화된 운동 통계 제공에만 사용됩니다.',
              style: AppTextStyles.body2.normalMedium.copyWith(
                color: colors.labelAlternative,
              ),
            ),
          ],
        ),
      ),
      secondaryButtonText: '취소',
      primaryButtonText: '확인',
      onSecondaryButtonPressed: () {
        AmplitudeAnalytics.logEvent('apple_health_permission_dialog_cancelled');
      },
      onPrimaryButtonPressed: () async {
        AmplitudeAnalytics.logEvent('apple_health_permission_dialog_confirmed');
        // 실제 권한 요청 진행
        await ref
            .read(syncScreenNotifierProvider.notifier)
            .connectAppleHealth();
      },
      barrierDismissible: true,
      showCloseButton: false,
    );
  }

  /// 권한 항목 위젯
  Widget _buildPermissionItem(String text) {
    final SemanticColors colors = context.semanticColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2.normalMedium.copyWith(
                color: colors.labelNormal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Health Connect 동기화
  Future<void> _syncHealthConnectData() async {
    await _syncHealthData(
      serviceName: 'Health Connect',
      buttonEvent: 'workout_sync_health_connect',
      successEvent: 'workout_sync_health_connect_success',
      failedEvent: 'workout_sync_health_connect_failed',
      syncMethod:
          () => ref.read(workoutSyncFacadeProvider).syncHealthConnectData(),
    );
  }

  /// Samsung Health 동기화
  Future<void> _syncSamsungHealthData() async {
    await _syncHealthData(
      serviceName: 'Samsung Health',
      buttonEvent: 'workout_sync_samsung_health',
      successEvent: 'workout_sync_samsung_health_success',
      failedEvent: 'workout_sync_samsung_health_failed',
      syncMethod:
          () => ref.read(workoutSyncFacadeProvider).syncSamsungHealthData(),
    );
  }

  /// Garmin Connect 권한 요청
  Future<void> _requestGarminConnectPermission() async {
    AmplitudeAnalytics.logButtonClick('workout_sync_garmin_connect');

    try {
      final WorkoutSyncFacade facade = ref.read(workoutSyncFacadeProvider);
      final AppResult<IntegrationAuth> result =
          await facade.requestGarminPermission();

      if (result.isSuccess) {
        final IntegrationAuth data = result.dataOrNull!;
        final String authUrl = data.url;

        if (authUrl.isNotEmpty) {
          if (mounted) {
            WebViewNavigation.navigateToWebView(
              context,
              url: authUrl,
              title: 'Garmin Connect 연동',
            );
            // 연동 상태 다시 확인
            ref
                .read(syncScreenNotifierProvider.notifier)
                .checkIntegrationStatus();
          }
        } else {
          if (mounted) {
            showErrorMessage(context, '연동 링크를 받을 수 없습니다.');
          }
        }
      } else {
        if (mounted) {
          showErrorMessage(
            context,
            'Garmin Connect 권한 요청 실패: ${result.exceptionOrNull?.message}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (e is PlatformException) {
          showErrorMessage(context, '지원하지 않는 플랫폼입니다');
        } else {
          showErrorMessage(context, 'Garmin Connect 권한 요청 중 오류가 발생했습니다');
        }
      }
    }
  }

  /// Suunto 권한 요청
  Future<void> _requestSuuntoPermission() async {
    AmplitudeAnalytics.logButtonClick('workout_sync_suunto');

    try {
      final WorkoutSyncFacade facade = ref.read(workoutSyncFacadeProvider);
      final AppResult<IntegrationAuth> result =
          await facade.requestSuuntoPermission();

      if (result.isSuccess) {
        final IntegrationAuth data = result.dataOrNull!;
        final String authUrl = data.url;

        if (authUrl.isNotEmpty) {
          if (mounted) {
            WebViewNavigation.navigateToWebView(
              context,
              url: authUrl,
              title: 'Suunto 연동',
            );
            // 연동 상태 다시 확인
            ref
                .read(syncScreenNotifierProvider.notifier)
                .checkIntegrationStatus();
          }
        } else {
          if (mounted) {
            showErrorMessage(context, '연동 링크를 받을 수 없습니다.');
          }
        }
      } else {
        if (mounted) {
          showErrorMessage(
            context,
            'Suunto 권한 요청 실패: ${result.exceptionOrNull?.message}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (e is PlatformException) {
          showErrorMessage(context, '지원하지 않는 플랫폼입니다');
        } else {
          showErrorMessage(context, 'Suunto 권한 요청 중 오류가 발생했습니다');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final SyncScreenState syncState = ref.watch(syncScreenNotifierProvider);

    // 연동 해제 결과 메시지 표시 (useEffect 패턴)
    ref.listen<SyncScreenState>(syncScreenNotifierProvider, (
      SyncScreenState? previous,
      SyncScreenState next,
    ) {
      if (next.lastDisconnectResult != null &&
          (previous?.lastDisconnectResult == null ||
              previous?.lastDisconnectResult != next.lastDisconnectResult)) {
        final DisconnectResult result = next.lastDisconnectResult!;
        if (result.isSuccess) {
          showSuccessMessage(context, '${result.serviceName} 연동이 해제되었습니다.');
        } else {
          showErrorMessage(context, '${result.serviceName} 연동 해제 실패');
        }
        // 결과 초기화 (다음 프레임에서 실행)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(syncScreenNotifierProvider.notifier).clearDisconnectResult();
        });
      }
    });

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: CustomAppBar(
        title: '동기화 설정',
        leading: CustomIconButton(
          onTap: () => Navigator.of(context).pop(),
          icon: Icons.arrow_back_ios_new,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Apple Health Kit 섹션
              _buildSyncButton(
                provider: HealthProvider.appleHealthKit,
                isConnected:
                    syncState.connectionStatus[HealthProvider.appleHealthKit] ??
                    false,
                isLoading: syncState.isLoading,
                onPressed: _syncAppleHealthKit,
                onDisconnectPressed:
                    () => _showDisconnectModal(
                      HealthProvider.appleHealthKit.serviceName,
                    ),
              ),

              const SizedBox(height: 16),

              // Google Health Connect 섹션
              _buildSyncButton(
                provider: HealthProvider.healthConnect,
                isConnected:
                    syncState.connectionStatus[HealthProvider.healthConnect] ??
                    false,
                isLoading: syncState.isLoading,
                onPressed: _syncHealthConnectData,
                onDisconnectPressed:
                    () => _showDisconnectModal(
                      HealthProvider.healthConnect.serviceName,
                    ),
              ),

              const SizedBox(height: 16),

              // Samsung Health 섹션
              _buildSyncButton(
                provider: HealthProvider.samsungHealth,
                isConnected:
                    syncState.connectionStatus[HealthProvider.samsungHealth] ??
                    false,
                isLoading: syncState.isLoading,
                onPressed: _syncSamsungHealthData,
                onDisconnectPressed:
                    () => _showDisconnectModal(
                      HealthProvider.samsungHealth.serviceName,
                    ),
              ),

              const SizedBox(height: 16),

              // Garmin Connect 섹션
              _buildSyncButton(
                provider: HealthProvider.garmin,
                isConnected:
                    syncState.connectionStatus[HealthProvider.garmin] ?? false,
                isLoading: syncState.isLoading,
                onPressed: _requestGarminConnectPermission,
                onDisconnectPressed:
                    () =>
                        _showDisconnectModal(HealthProvider.garmin.serviceName),
              ),

              const SizedBox(height: 16),

              // Suunto 섹션
              _buildSyncButton(
                provider: HealthProvider.suunto,
                isConnected:
                    syncState.connectionStatus[HealthProvider.suunto] ?? false,
                isLoading: syncState.isLoading,
                onPressed: _requestSuuntoPermission,
                onDisconnectPressed:
                    () =>
                        _showDisconnectModal(HealthProvider.suunto.serviceName),
              ),

              if (syncState.isLoading) ...<Widget>[
                const SizedBox(height: 24),
                const Center(child: AppLoadingIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 동기화 버튼 위젯 빌드
  Widget _buildSyncButton({
    required HealthProvider provider,
    required bool isConnected,
    required bool isLoading,
    required VoidCallback onPressed,
    required VoidCallback onDisconnectPressed,
  }) {
    final SemanticColors colors = context.semanticColor;

    return SizedBox(
      width: double.infinity,
      child:
          isConnected
              ? ButtonSolid(
                text: isLoading ? '동기화 중...' : '${provider.serviceName} 연동됨',
                textColor: colors.staticWhite,
                backgroundColor: colors.primaryNormal,
                onPressed: isLoading ? null : onDisconnectPressed,
              )
              : ButtonOutlined(
                text: isLoading ? '동기화 중...' : '${provider.serviceName} 동기화',
                textColor: colors.labelNormal,
                borderColor: colors.lineNormalNormal,
                onPressed: isLoading ? null : onPressed,
              ),
    );
  }
}
