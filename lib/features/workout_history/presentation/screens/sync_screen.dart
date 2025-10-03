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
import 'package:urban_breeze/features/workout_history/presentation/notifiers/sync_screen_notifier.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
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

  /// 연동 해제 확인 모달 표시
  Future<void> _showDisconnectModal(String serviceName) async {
    await ModalShow.show(
      context: context,
      title: '연동 해제',
      content: Text('$serviceName 연동을 해제하시겠습니까?'),
      primaryButtonText: '해제',
      secondaryButtonText: '취소',
      onPrimaryButtonPressed: () {
        ref
            .read(syncScreenNotifierProvider.notifier)
            .disconnectService(serviceName);
      },
      onSecondaryButtonPressed: () {
        // 취소 버튼 - 아무것도 하지 않음 (모달은 자동으로 닫힘)
      },
    );
  }

  /// Apple Health Kit 동기화
  Future<void> _syncAppleHealthKit() async {
    await ref.read(syncScreenNotifierProvider.notifier).connectAppleHealth();
  }

  /// Health Connect 동기화
  Future<void> _syncHealthConnectData() async {
    setState(() {
      // 로딩 상태는 notifier에서 관리
    });

    try {
      final WorkoutSyncFacade facade = ref.read(workoutSyncFacadeProvider);
      final AppResult<Map<String, dynamic>?> result =
          await facade.syncHealthConnectData();

      if (result.isSuccess) {
        if (mounted) {
          showSuccessMessage(context, 'Health Connect 데이터가 동기화되었습니다.');
        }
      } else {
        if (mounted) {
          showErrorMessage(
            context,
            'Health Connect 데이터 가져오기 실패: ${result.exceptionOrNull?.message}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (e is PlatformException) {
          showErrorMessage(context, '지원하지 않는 플랫폼입니다');
        } else {
          showErrorMessage(context, 'Health Connect 데이터 가져오기 중 오류가 발생했습니다');
        }
      }
    }
  }

  /// Samsung Health 동기화
  Future<void> _syncSamsungHealthData() async {
    setState(() {
      // 로딩 상태는 notifier에서 관리
    });

    try {
      final WorkoutSyncFacade facade = ref.read(workoutSyncFacadeProvider);
      final AppResult<Map<String, dynamic>?> result =
          await facade.syncSamsungHealthData();

      if (result.isSuccess) {
        if (mounted) {
          showSuccessMessage(context, 'Samsung Health 데이터가 동기화되었습니다.');
        }
      } else {
        if (mounted) {
          showErrorMessage(
            context,
            'Samsung Health 데이터 가져오기 실패: ${result.exceptionOrNull?.message}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (e is PlatformException) {
          showErrorMessage(context, '지원하지 않는 플랫폼입니다');
        } else {
          showErrorMessage(context, 'Samsung Health 데이터 가져오기 중 오류가 발생했습니다');
        }
      }
    }
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
