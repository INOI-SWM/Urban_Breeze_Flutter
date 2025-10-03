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
import 'package:urban_breeze/features/workout_history/application/use_cases/connect_apple_health_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/delete_provider_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/get_api_usage_use_case.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/api_usage.dart';
import 'package:urban_breeze/features/workout_history/domain/enums/health_provider.dart';
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
  bool _isLoading = false;
  StreamSubscription<IntegrationCallback>? _deepLinkSubscription;

  // 연동 상태 관리
  bool _isAppleHealthConnected = false;
  bool _isHealthConnectConnected = false;
  bool _isSamsungHealthConnected = false;
  bool _isGarminConnected = false;
  bool _isSuuntoConnected = false;

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
    _checkIntegrationStatus();
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
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
        _disconnectService(serviceName);
      },
      onSecondaryButtonPressed: () {
        // 취소 버튼 - 아무것도 하지 않음 (모달은 자동으로 닫힘)
      },
    );
  }

  /// 서비스 연동 해제
  Future<void> _disconnectService(String serviceName) async {
    setState(() {
      _isLoading = true;
    });

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
        // 연동 해제 성공 이벤트
        AmplitudeAnalytics.logEvent(
          'provider_disconnect_success',
          properties: <String, dynamic>{'provider_name': providerName},
        );
        if (mounted) {
          showSuccessMessage(context, '$serviceName 연동이 해제되었습니다.');
        }
      } else {
        // 연동 해제 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'provider_disconnect_failed',
          properties: <String, dynamic>{
            'provider_name': providerName,
            'error_message': result.exceptionOrNull?.message ?? 'Unknown error',
          },
        );
        if (mounted) {
          showErrorMessage(
            context,
            '$serviceName 연동 해제 실패: ${result.exceptionOrNull?.message}',
          );
        }
      }
    } catch (e) {
      // 연동 해제 예외 이벤트
      AmplitudeAnalytics.logEvent(
        'provider_disconnect_exception',
        properties: <String, dynamic>{
          'provider_name': serviceName,
          'error_message': e.toString(),
        },
      );
      if (mounted) {
        showErrorMessage(context, '$serviceName 연동 해제 중 오류가 발생했습니다');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      // 연동 상태 다시 확인
      _checkIntegrationStatus();
    }
  }

  /// 서비스명을 API providerName으로 변환
  String _getProviderName(String serviceName) {
    for (final HealthProvider provider in HealthProvider.values) {
      if (provider.serviceName == serviceName) {
        return provider.displayName;
      }
    }
    return serviceName;
  }

  /// 연동 상태 확인
  Future<void> _checkIntegrationStatus() async {
    try {
      final GetApiUsageUseCase getApiUsageUseCase = ref.read(
        getApiUsageUseCaseProvider,
      );
      final AppResult<ApiUsage> result = await getApiUsageUseCase.execute();

      if (result.isSuccess && mounted) {
        final ApiUsage apiUsage = result.dataOrNull!;
        setState(() {
          // 각 서비스의 연동 상태 확인
          _isAppleHealthConnected = apiUsage.providerSyncInfos.any(
            (ProviderSyncInfo provider) =>
                provider.providerName ==
                    HealthProvider.appleHealthKit.displayName &&
                provider.isActive,
          );
          _isHealthConnectConnected = apiUsage.providerSyncInfos.any(
            (ProviderSyncInfo provider) =>
                provider.providerName ==
                    HealthProvider.healthConnect.displayName &&
                provider.isActive,
          );
          _isSamsungHealthConnected = apiUsage.providerSyncInfos.any(
            (ProviderSyncInfo provider) =>
                provider.providerName ==
                    HealthProvider.samsungHealth.displayName &&
                provider.isActive,
          );
          _isGarminConnected = apiUsage.providerSyncInfos.any(
            (ProviderSyncInfo provider) =>
                provider.providerName == HealthProvider.garmin.displayName &&
                provider.isActive,
          );
          _isSuuntoConnected = apiUsage.providerSyncInfos.any(
            (ProviderSyncInfo provider) =>
                provider.providerName == HealthProvider.suunto.displayName &&
                provider.isActive,
          );
        });
      }
    } catch (e) {
      // 연동 상태 확인 실패 시 기본값 유지
      debugPrint('연동 상태 확인 실패: $e');
    }
  }

  /// Deep Link 콜백 처리
  void _handleIntegrationCallback(IntegrationCallback callback) {
    debugPrint('연동 콜백 수신: $callback');

    if (!mounted) return;

    if (callback.isSuccess) {
      showSuccessMessage(context, '연동이 성공하였습니다.');
    } else {
      showErrorMessage(context, '연동이 실패하였습니다.');
    }
  }

  // Apple Health Kit 통합 동기화 (Terra API 사용)
  Future<void> _syncAppleHealthKit() async {
    // Apple Health 동기화 버튼 클릭 이벤트
    AmplitudeAnalytics.logButtonClick('workout_sync_apple_health');
    await _syncAppleHealthData();
  }

  // Google Health Connect 통합 동기화 (Terra API 사용)
  Future<void> _syncGoogleHealthConnect() async {
    // Health Connect 동기화 버튼 클릭 이벤트
    AmplitudeAnalytics.logButtonClick('workout_sync_health_connect');
    await _syncHealthConnectData();
  }

  // Apple Health Kit 연동 설정
  Future<void> _syncAppleHealthData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ConnectAppleHealthUseCase connectAppleHealthUseCase = ref.read(
        connectAppleHealthUseCaseProvider,
      );
      final AppResult<void> result = await connectAppleHealthUseCase.execute();

      if (result.isSuccess) {
        // Apple Health Kit 연동 성공 이벤트
        AmplitudeAnalytics.logEvent(
          'workout_sync_apple_health_success',
          properties: <String, dynamic>{'sync_method': 'direct'},
        );
        if (mounted) {
          showSuccessMessage(context, 'Apple Health Kit 연동이 완료되었습니다!');
          // 연동 상태 다시 확인
          _checkIntegrationStatus();
        }
      } else {
        // Apple Health Kit 연동 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'workout_sync_apple_health_failed',
          properties: <String, dynamic>{
            'error_message': result.exceptionOrNull?.message ?? 'Unknown error',
          },
        );
        if (mounted) {
          showErrorMessage(
            context,
            'Apple Health Kit 연동 실패: ${result.exceptionOrNull?.message}',
          );
        }
      }
    } catch (e) {
      // Apple Health Kit 연동 예외 이벤트
      AmplitudeAnalytics.logEvent(
        'workout_sync_apple_health_exception',
        properties: <String, dynamic>{'error_message': e.toString()},
      );
      if (mounted) {
        if (e is PlatformException) {
          showErrorMessage(context, '지원하지 않는 플랫폼입니다');
        } else {
          showErrorMessage(context, 'Apple Health Kit 연동 중 오류가 발생했습니다');
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Health Connect에서 데이터 가져오기 (Terra API 사용)
  Future<void> _syncHealthConnectData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final WorkoutSyncFacade facade = ref.read(workoutSyncFacadeProvider);
      final AppResult<Map<String, dynamic>?> result =
          await facade.syncHealthConnectData();

      if (result.isSuccess) {
        final Map<String, dynamic>? data = result.dataOrNull;
        if (data != null &&
            data['message']?.toString().contains('webhook') == true) {
          // Health Connect 동기화 성공 (웹훅) 이벤트
          AmplitudeAnalytics.logEvent(
            'workout_sync_health_connect_success',
            properties: <String, dynamic>{'sync_method': 'webhook'},
          );
          if (mounted) {
            showSuccessMessage(context, 'Health Connect 데이터 가져오기 완료!');
          }
        } else {
          // Health Connect 동기화 성공 (직접) 이벤트
          AmplitudeAnalytics.logEvent(
            'workout_sync_health_connect_success',
            properties: <String, dynamic>{
              'sync_method': 'direct',
              'data_count': data?.length ?? 0,
            },
          );
          if (mounted) {
            showSuccessMessage(context, 'Health Connect 데이터 가져오기 완료!');
          }
        }
      } else {
        // Health Connect 동기화 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'workout_sync_health_connect_failed',
          properties: <String, dynamic>{
            'error_message': result.exceptionOrNull?.message ?? 'Unknown error',
          },
        );
        if (mounted) {
          showErrorMessage(context, 'Health Connect 데이터 가져오기 실패');
        }
      }
    } catch (e) {
      // Health Connect 동기화 예외 이벤트
      AmplitudeAnalytics.logEvent(
        'workout_sync_health_connect_exception',
        properties: <String, dynamic>{'error_message': e.toString()},
      );
      if (mounted) {
        if (e is PlatformException) {
          showErrorMessage(context, '지원하지 않는 플랫폼입니다');
        } else {
          showErrorMessage(context, 'Health Connect 데이터 가져오기 중 오류가 발생했습니다');
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Samsung Health에서 데이터 가져오기 (Terra API 사용)
  Future<void> _syncSamsungHealthData() async {
    // Samsung Health 동기화 버튼 클릭 이벤트
    AmplitudeAnalytics.logButtonClick('workout_sync_samsung_health');

    setState(() {
      _isLoading = true;
    });

    try {
      final WorkoutSyncFacade facade = ref.read(workoutSyncFacadeProvider);
      final AppResult<Map<String, dynamic>?> result =
          await facade.syncSamsungHealthData();

      if (result.isSuccess) {
        final Map<String, dynamic>? data = result.dataOrNull;
        if (data != null &&
            data['message']?.toString().contains('webhook') == true) {
          // Samsung Health 동기화 성공 (웹훅) 이벤트
          AmplitudeAnalytics.logEvent(
            'workout_sync_samsung_health_success',
            properties: <String, dynamic>{'sync_method': 'webhook'},
          );
          if (mounted) {
            showSuccessMessage(
              context,
              'Samsung Health 데이터 가져오기 완료! 웹훅을 통해 데이터가 전송됩니다.',
            );
          }
        } else {
          // Samsung Health 동기화 성공 (직접) 이벤트
          AmplitudeAnalytics.logEvent(
            'workout_sync_samsung_health_success',
            properties: <String, dynamic>{
              'sync_method': 'direct',
              'data_count': data?.length ?? 0,
            },
          );
          if (mounted) {
            showSuccessMessage(context, 'Samsung Health 데이터 가져오기 완료!');
          }
        }
      } else {
        // Samsung Health 동기화 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'workout_sync_samsung_health_failed',
          properties: <String, dynamic>{
            'error_message': result.exceptionOrNull?.message ?? 'Unknown error',
          },
        );
        if (mounted) {
          showErrorMessage(
            context,
            'Samsung Health 데이터 가져오기 실패: ${result.exceptionOrNull?.message}',
          );
        }
      }
    } catch (e) {
      // Samsung Health 동기화 예외 이벤트
      AmplitudeAnalytics.logEvent(
        'workout_sync_samsung_health_exception',
        properties: <String, dynamic>{'error_message': e.toString()},
      );
      if (mounted) {
        if (e is PlatformException) {
          showErrorMessage(context, '지원하지 않는 플랫폼입니다');
        } else {
          showErrorMessage(context, 'Samsung Health 데이터 가져오기 중 오류가 발생했습니다');
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Garmin Connect 권한 요청
  Future<void> _requestGarminConnectPermission() async {
    // Garmin Connect 권한 요청 버튼 클릭 이벤트
    AmplitudeAnalytics.logButtonClick('workout_sync_garmin_connect');

    setState(() {
      _isLoading = true;
    });

    try {
      final WorkoutSyncFacade facade = ref.read(workoutSyncFacadeProvider);
      final AppResult<IntegrationAuth> result =
          await facade.requestGarminPermission();

      if (result.isSuccess) {
        final IntegrationAuth data = result.dataOrNull!;
        final String authUrl = data.url;

        if (authUrl.isNotEmpty) {
          // 연동 링크를 웹뷰로 표시
          if (mounted) {
            WebViewNavigation.navigateToWebView(
              context,
              url: authUrl,
              title: 'Garmin Connect 연동',
            );
            // 연동 상태 다시 확인
            _checkIntegrationStatus();
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Suunto 권한 요청
  Future<void> _requestSuuntoPermission() async {
    // Suunto 권한 요청 버튼 클릭 이벤트
    AmplitudeAnalytics.logButtonClick('workout_sync_suunto');

    setState(() {
      _isLoading = true;
    });

    try {
      final WorkoutSyncFacade facade = ref.read(workoutSyncFacadeProvider);
      final AppResult<IntegrationAuth> result =
          await facade.requestSuuntoPermission();

      if (result.isSuccess) {
        final IntegrationAuth data = result.dataOrNull!;
        final String authUrl = data.url;

        if (authUrl.isNotEmpty) {
          // 연동 링크를 웹뷰로 표시
          if (mounted) {
            WebViewNavigation.navigateToWebView(
              context,
              url: authUrl,
              title: 'Suunto 연동',
            );
            // 연동 상태 다시 확인
            _checkIntegrationStatus();
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

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
              SizedBox(
                width: double.infinity,
                child:
                    _isAppleHealthConnected
                        ? ButtonSolid(
                          text:
                              _isLoading ? '동기화 중...' : 'Apple Health Kit 연동됨',
                          textColor: colors.staticWhite,
                          backgroundColor: colors.primaryNormal,
                          onPressed:
                              _isLoading
                                  ? null
                                  : () => _showDisconnectModal(
                                    HealthProvider.appleHealthKit.serviceName,
                                  ),
                        )
                        : ButtonOutlined(
                          text:
                              _isLoading ? '동기화 중...' : 'Apple Health Kit 동기화',
                          textColor: colors.labelNormal,
                          borderColor: colors.lineNormalNormal,
                          onPressed: _isLoading ? null : _syncAppleHealthKit,
                        ),
              ),

              const SizedBox(height: 16),

              // Google Health Connect 섹션
              SizedBox(
                width: double.infinity,
                child:
                    _isHealthConnectConnected
                        ? ButtonSolid(
                          text:
                              _isLoading
                                  ? '동기화 중...'
                                  : 'Google Health Connect 연동됨',
                          textColor: colors.staticWhite,
                          backgroundColor: colors.primaryNormal,
                          onPressed:
                              _isLoading
                                  ? null
                                  : () => _showDisconnectModal(
                                    HealthProvider.healthConnect.serviceName,
                                  ),
                        )
                        : ButtonOutlined(
                          text:
                              _isLoading
                                  ? '동기화 중...'
                                  : 'Google Health Connect 동기화',
                          textColor: colors.labelNormal,
                          borderColor: colors.lineNormalNormal,
                          onPressed:
                              _isLoading ? null : _syncGoogleHealthConnect,
                        ),
              ),

              const SizedBox(height: 16),

              // Samsung Health 섹션
              SizedBox(
                width: double.infinity,
                child:
                    _isSamsungHealthConnected
                        ? ButtonSolid(
                          text: _isLoading ? '동기화 중...' : 'Samsung Health 연동됨',
                          textColor: colors.staticWhite,
                          backgroundColor: colors.primaryNormal,
                          onPressed:
                              _isLoading
                                  ? null
                                  : () => _showDisconnectModal(
                                    HealthProvider.samsungHealth.serviceName,
                                  ),
                        )
                        : ButtonOutlined(
                          text: _isLoading ? '동기화 중...' : 'Samsung Health 동기화',
                          textColor: colors.labelNormal,
                          borderColor: colors.lineNormalNormal,
                          onPressed: _isLoading ? null : _syncSamsungHealthData,
                        ),
              ),
              const SizedBox(height: 16),
              // Garmin Connect 섹션
              SizedBox(
                width: double.infinity,
                child:
                    _isGarminConnected
                        ? ButtonSolid(
                          text: _isLoading ? '연동 중...' : 'Garmin Connect 연동됨',
                          textColor: colors.staticWhite,
                          backgroundColor: colors.primaryNormal,
                          onPressed:
                              _isLoading
                                  ? null
                                  : () => _showDisconnectModal(
                                    HealthProvider.garmin.serviceName,
                                  ),
                        )
                        : ButtonOutlined(
                          text: _isLoading ? '연동 중...' : 'Garmin Connect 연동',
                          textColor: colors.labelNormal,
                          borderColor: colors.lineNormalNormal,
                          onPressed:
                              _isLoading
                                  ? null
                                  : _requestGarminConnectPermission,
                        ),
              ),
              const SizedBox(height: 16),
              // Suunto 섹션
              SizedBox(
                width: double.infinity,
                child:
                    _isSuuntoConnected
                        ? ButtonSolid(
                          text: _isLoading ? '연동 중...' : 'Suunto 연동됨',
                          textColor: colors.staticWhite,
                          backgroundColor: colors.primaryNormal,
                          onPressed:
                              _isLoading
                                  ? null
                                  : () => _showDisconnectModal(
                                    HealthProvider.suunto.serviceName,
                                  ),
                        )
                        : ButtonOutlined(
                          text: _isLoading ? '연동 중...' : 'Suunto 연동',
                          textColor: colors.labelNormal,
                          borderColor: colors.lineNormalNormal,
                          onPressed:
                              _isLoading ? null : _requestSuuntoPermission,
                        ),
              ),

              if (_isLoading) ...<Widget>[
                const SizedBox(height: 24),
                const Center(child: AppLoadingIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
