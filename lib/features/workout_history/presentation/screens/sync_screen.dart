import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/domain/entities/integration_auth.dart';
import 'package:urban_breeze/features/integration/domain/enums/health_provider.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';
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
  @override
  void initState() {
    super.initState();
    // 화면 조회 이벤트
    AmplitudeAnalytics.logScreenView('workout_sync_screen');

    // 연동 상태 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncScreenNotifierProvider.notifier).checkIntegrationStatus();
    });
  }

  /// 공통 헬스 앱 연결 메서드
  Future<void> _syncHealthData({
    required HealthProvider provider,
    required String serviceName,
    required String buttonEvent,
    required String successEvent,
    required String failedEvent,
    required Future<AppResult<void>> Function() syncMethod,
  }) async {
    AmplitudeAnalytics.logButtonClick(buttonEvent);

    // 서비스별 로딩 상태 표시
    ref
        .read(syncScreenNotifierProvider.notifier)
        .setServiceLoading(provider, true);

    try {
      final AppResult<void> result = await syncMethod();

      if (result.isSuccess) {
        AmplitudeAnalytics.logEvent(
          successEvent,
          properties: <String, dynamic>{'sync_method': 'connect_only'},
        );
        if (mounted) {
          showSuccessMessage(context, '$serviceName 연결이 완료되었습니다...');
        }

        await Future<void>.delayed(const Duration(seconds: 2));

        // 연동 상태 다시 확인
        await ref
            .read(syncScreenNotifierProvider.notifier)
            .checkIntegrationStatus();

        if (mounted) {
          showSuccessMessage(context, '$serviceName 연동이 완료되었습니다! 🎉');
        }
      } else {
        // 실패 시 예외 타입에 따라 다른 메시지 표시
        final String errorMessage =
            result.exceptionOrNull?.message ?? 'Unknown error';

        AmplitudeAnalytics.logEvent(
          failedEvent,
          properties: <String, dynamic>{'error_message': errorMessage},
        );

        // 권한 다이얼로그가 닫히는 애니메이션 대기 (500ms)
        await Future<void>.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          // iOS에서 Health Connect나 Samsung Health 사용 시 플랫폼 체크
          if (result.exceptionOrNull is PlatformException) {
            showErrorMessage(context, '지원하지 않는 플랫폼입니다');
          } else {
            // Terra SDK의 실제 에러 메시지 표시
            showErrorMessage(context, '연동에 실패했습니다.');
          }
        }
      }
    } finally {
      // 로딩 상태 해제도 약간 딜레이 (에러 메시지와 겹치지 않도록)
      await Future<void>.delayed(const Duration(milliseconds: 300));
      ref
          .read(syncScreenNotifierProvider.notifier)
          .setServiceLoading(provider, false);
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
    // 플랫폼 체크 (iOS 전용)
    if (!Platform.isIOS) {
      showErrorMessage(context, 'Apple Health는 iOS 전용 기능입니다.');
      AmplitudeAnalytics.logEvent('apple_health_wrong_platform_clicked');
      return;
    }

    AmplitudeAnalytics.logButtonClick('workout_sync_apple_health');

    // 권한 요청 전 안내 모달 표시
    await _showHealthKitPermissionInfoDialog();
  }

  /// HealthKit 권한 안내 다이얼로그 표시
  Future<void> _showHealthKitPermissionInfoDialog() async {
    await _showHealthPermissionDialog(
      title: 'Apple Health 연동',
      serviceName: 'Apple HealthKit',
      cancelEvent: 'apple_health_permission_dialog_cancelled',
      confirmEvent: 'apple_health_permission_dialog_confirmed',
      onConfirm: () async {
        await ref
            .read(syncScreenNotifierProvider.notifier)
            .connectAppleHealth();
      },
    );
  }

  /// 공통 헬스 권한 안내 다이얼로그
  Future<void> _showHealthPermissionDialog({
    required String title,
    required String serviceName,
    required String cancelEvent,
    required String confirmEvent,
    required Future<void> Function() onConfirm,
  }) async {
    final SemanticColors colors = context.semanticColor;

    await ModalShow.show<void>(
      context: context,
      title: title,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                'Urban Breeze는 $serviceName을 통해\n다음 건강 데이터를 읽어옵니다',
                style: AppTextStyles.body2.normalBold.copyWith(
                  color: colors.labelStrong,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.backgroundElevatedNormal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildDetailedPermissionItem(
                    '🚴 사이클링 운동 기록',
                    '운동 시작/종료 시간, 운동 종류',
                    colors,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailedPermissionItem(
                    '❤️ 심박수 데이터',
                    '실시간 심박수로 운동 강도 분석',
                    colors,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailedPermissionItem(
                    '📍 이동 거리 및 속도',
                    '라이딩 거리와 속도 통계 제공',
                    colors,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailedPermissionItem(
                    '🔥 소모 칼로리',
                    '운동으로 소모한 에너지 계산',
                    colors,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailedPermissionItem(
                    '🗺️ GPS 경로 데이터',
                    '이동 경로 및 고도 정보 시각화',
                    colors,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.backgroundNormalNormal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: colors.primaryNormal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '데이터 사용 목적',
                        style: AppTextStyles.caption1.bold.copyWith(
                          color: colors.labelStrong,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 운동 기록 관리 및 통합\n• 주간/월간 성과 추적\n• 개인화된 운동 통계 제공\n• 건강 목표 달성도 분석',
                    style: AppTextStyles.caption1.medium.copyWith(
                      color: colors.labelNormal,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: colors.primaryNormal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '개인정보 보호',
                        style: AppTextStyles.caption1.bold.copyWith(
                          color: colors.labelStrong,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$serviceName 데이터는 안전하게 암호화되어 저장되며, 사용자의 동의 없이 제3자와 공유되지 않습니다.',
                    style: AppTextStyles.caption1.medium.copyWith(
                      color: colors.labelNormal,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      secondaryButtonText: '취소',
      primaryButtonText: '확인',
      onSecondaryButtonPressed: () {
        AmplitudeAnalytics.logEvent(cancelEvent);
      },
      onPrimaryButtonPressed: () async {
        AmplitudeAnalytics.logEvent(confirmEvent);
        await onConfirm();
      },
      barrierDismissible: true,
      showCloseButton: false,
    );
  }

  /// 상세 권한 항목 위젯 (설명 포함)
  Widget _buildDetailedPermissionItem(
    String title,
    String description,
    SemanticColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: AppTextStyles.body2.normalBold.copyWith(
            color: colors.labelStrong,
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            description,
            style: AppTextStyles.caption1.medium.copyWith(
              color: colors.labelAlternative,
            ),
          ),
        ),
      ],
    );
  }

  /// Terra 기반 헬스 연결 (Health Connect, Samsung Health)
  Future<void> _syncTerraHealthData({
    required HealthProvider provider,
    required String serviceName,
    required String buttonEvent,
    required String dialogTitle,
    required Future<AppResult<void>> Function() syncMethod,
  }) async {
    // 플랫폼 체크 (Android 전용)
    if (!Platform.isAndroid) {
      showErrorMessage(context, '$serviceName는 Android 전용 기능입니다.');
      AmplitudeAnalytics.logEvent('${buttonEvent}_wrong_platform_clicked');
      return;
    }

    AmplitudeAnalytics.logButtonClick(buttonEvent);

    // 권한 요청 전 안내 모달 표시
    await _showHealthPermissionDialog(
      title: dialogTitle,
      serviceName: serviceName,
      cancelEvent: '${buttonEvent}_permission_dialog_cancelled',
      confirmEvent: '${buttonEvent}_permission_dialog_confirmed',
      onConfirm: () async {
        await _syncHealthData(
          provider: provider,
          serviceName: serviceName,
          buttonEvent: buttonEvent,
          successEvent: '${buttonEvent}_success',
          failedEvent: '${buttonEvent}_failed',
          syncMethod: syncMethod,
        );
      },
    );
  }

  /// Health Connect 동기화
  Future<void> _syncHealthConnectData() async {
    await _syncTerraHealthData(
      provider: HealthProvider.healthConnect,
      serviceName: 'Health Connect',
      buttonEvent: 'workout_sync_health_connect',
      dialogTitle: 'Google Health Connect 연동',
      syncMethod:
          () => ref.read(workoutSyncFacadeProvider).syncHealthConnectData(),
    );
  }

  /// Samsung Health 동기화
  Future<void> _syncSamsungHealthData() async {
    await _syncTerraHealthData(
      provider: HealthProvider.samsungHealth,
      serviceName: 'Samsung Health',
      buttonEvent: 'workout_sync_samsung_health',
      dialogTitle: 'Samsung Health 연동',
      syncMethod:
          () => ref.read(workoutSyncFacadeProvider).syncSamsungHealthData(),
    );
  }

  /// 공통 OAuth 기반 권한 요청 (Garmin, Suunto 등)
  Future<void> _requestOAuthPermission({
    required String serviceName,
    required String buttonEvent,
    required String successEvent,
    required String failedEvent,
    required Future<AppResult<IntegrationAuth>> Function() requestMethod,
  }) async {
    AmplitudeAnalytics.logButtonClick(buttonEvent);

    try {
      final AppResult<IntegrationAuth> result = await requestMethod();

      if (result.isSuccess) {
        final IntegrationAuth data = result.dataOrNull!;
        final String authUrl = data.url;

        if (authUrl.isNotEmpty && mounted) {
          await WebViewNavigation.navigateToWebView(
            context,
            url: authUrl,
            title: '$serviceName 연동',
            onAuthSuccess: () {
              AmplitudeAnalytics.logEvent(
                successEvent,
                properties: <String, dynamic>{},
              );

              ref
                  .read(syncScreenNotifierProvider.notifier)
                  .checkIntegrationStatus();

              if (mounted) {
                showSuccessMessage(context, '$serviceName 연동이 완료되었습니다.');
              }
            },
            onAuthFailure: (String? reason) {
              AmplitudeAnalytics.logEvent(
                failedEvent,
                properties: <String, dynamic>{'reason': reason ?? 'unknown'},
              );

              if (mounted) {
                showErrorMessage(
                  context,
                  '$serviceName 연동에 실패했습니다.\n\n'
                  '잠시 후 다시 시도해 주세요.\n'
                  '문제가 지속될 경우 설정 > 문의하기를 통해\n'
                  '자세한 상황을 알려주시면 빠르게 도와드리겠습니다.',
                );
              }
            },
          );
        } else if (mounted) {
          showErrorMessage(context, '연동 링크를 받을 수 없습니다.');
        }
      } else if (mounted) {
        showErrorMessage(
          context,
          '$serviceName 권한 요청 실패: ${result.exceptionOrNull?.message}',
        );
      }
    } catch (e) {
      if (mounted) {
        if (e is PlatformException) {
          showErrorMessage(context, '지원하지 않는 플랫폼입니다');
        } else {
          showErrorMessage(context, '$serviceName 권한 요청 중 오류가 발생했습니다');
        }
      }
    }
  }

  /// Garmin Connect 권한 요청
  Future<void> _requestGarminConnectPermission() async {
    await _requestOAuthPermission(
      serviceName: 'Garmin Connect',
      buttonEvent: 'workout_sync_garmin_connect',
      successEvent: 'garmin_connect_auth_success',
      failedEvent: 'garmin_connect_auth_failed',
      requestMethod:
          () => ref.read(workoutSyncFacadeProvider).requestGarminPermission(),
    );
  }

  /// Suunto 권한 요청
  Future<void> _requestSuuntoPermission() async {
    await _requestOAuthPermission(
      serviceName: 'Suunto',
      buttonEvent: 'workout_sync_suunto',
      successEvent: 'suunto_auth_success',
      failedEvent: 'suunto_auth_failed',
      requestMethod:
          () => ref.read(workoutSyncFacadeProvider).requestSuuntoPermission(),
    );
  }

  /// Wahoo 권한 요청
  Future<void> _requestWahooPermission() async {
    await _requestOAuthPermission(
      serviceName: 'Wahoo',
      buttonEvent: 'workout_sync_wahoo',
      successEvent: 'wahoo_auth_success',
      failedEvent: 'wahoo_auth_failed',
      requestMethod:
          () => ref.read(workoutSyncFacadeProvider).requestWahooPermission(),
    );
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
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Apple Health Kit 섹션 (iOS 전용)
                  _buildSyncButton(
                    provider: HealthProvider.appleHealthKit,
                    isConnected:
                        syncState.connectionStatus[HealthProvider
                            .appleHealthKit] ??
                        false,
                    isLoading:
                        syncState.loadingStatus[HealthProvider
                            .appleHealthKit] ??
                        false,
                    onPressed: _syncAppleHealthKit,
                    onDisconnectPressed:
                        () => _showDisconnectModal(
                          HealthProvider.appleHealthKit.serviceName,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // Google Health Connect 섹션 (Android 전용)
                  _buildSyncButton(
                    provider: HealthProvider.healthConnect,
                    isConnected:
                        syncState.connectionStatus[HealthProvider
                            .healthConnect] ??
                        false,
                    isLoading:
                        syncState.loadingStatus[HealthProvider.healthConnect] ??
                        false,
                    onPressed: _syncHealthConnectData,
                    onDisconnectPressed:
                        () => _showDisconnectModal(
                          HealthProvider.healthConnect.serviceName,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // Samsung Health 섹션 (Android 전용)
                  _buildSyncButton(
                    provider: HealthProvider.samsungHealth,
                    isConnected:
                        syncState.connectionStatus[HealthProvider
                            .samsungHealth] ??
                        false,
                    isLoading:
                        syncState.loadingStatus[HealthProvider.samsungHealth] ??
                        false,
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
                        syncState.connectionStatus[HealthProvider.garmin] ??
                        false,
                    isLoading:
                        syncState.loadingStatus[HealthProvider.garmin] ?? false,
                    onPressed: _requestGarminConnectPermission,
                    onDisconnectPressed:
                        () => _showDisconnectModal(
                          HealthProvider.garmin.serviceName,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // Suunto 섹션
                  _buildSyncButton(
                    provider: HealthProvider.suunto,
                    isConnected:
                        syncState.connectionStatus[HealthProvider.suunto] ??
                        false,
                    isLoading:
                        syncState.loadingStatus[HealthProvider.suunto] ?? false,
                    onPressed: _requestSuuntoPermission,
                    onDisconnectPressed:
                        () => _showDisconnectModal(
                          HealthProvider.suunto.serviceName,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // Wahoo 섹션
                  _buildSyncButton(
                    provider: HealthProvider.wahoo,
                    isConnected:
                        syncState.connectionStatus[HealthProvider.wahoo] ??
                        false,
                    isLoading:
                        syncState.loadingStatus[HealthProvider.wahoo] ?? false,
                    onPressed: _requestWahooPermission,
                    onDisconnectPressed:
                        () => _showDisconnectModal(
                          HealthProvider.wahoo.serviceName,
                        ),
                  ),
                ],
              ),
            ),
          ),
          // 전체 화면 로딩 오버레이
          if (syncState.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.backgroundElevatedNormal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const AppLoadingIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        '헬스 데이터 연동 중...\n최대 1분 정도 소요될 수 있습니다.',
                        style: AppTextStyles.body2.normalRegular.copyWith(
                          color: colors.labelNormal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
