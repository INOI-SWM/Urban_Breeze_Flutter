import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/application/facades/terra_health_sync_facade.dart';
import 'package:urban_breeze/features/workout_history/di/workout_statistics_providers.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_outlined.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';

class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 화면 조회 이벤트
    AmplitudeAnalytics.logScreenView('workout_sync_screen');
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

  // Apple Health에서 데이터 가져오기 (초기화 + 연결 + 동기화)
  Future<void> _syncAppleHealthData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final TerraHealthSyncFacade facade = ref.read(
        terraHealthSyncFacadeProvider,
      );
      final AppResult<Map<String, dynamic>?> result =
          await facade.syncAppleHealthData();

      if (result.isSuccess) {
        final Map<String, dynamic>? data = result.dataOrNull;
        if (data != null &&
            data['message']?.toString().contains('webhook') == true) {
          // Apple Health 동기화 성공 (웹훅) 이벤트
          AmplitudeAnalytics.logEvent(
            'workout_sync_apple_health_success',
            properties: <String, dynamic>{'sync_method': 'webhook'},
          );
          _showInfoMessage('Apple Health 데이터 가져오기 완료! 웹훅을 통해 데이터가 전송됩니다.');
        } else {
          // Apple Health 동기화 성공 (직접) 이벤트
          AmplitudeAnalytics.logEvent(
            'workout_sync_apple_health_success',
            properties: <String, dynamic>{'sync_method': 'direct'},
          );
          _showSuccessMessage('Apple Health 데이터 가져오기 완료!');
        }
      } else {
        // Apple Health 동기화 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'workout_sync_apple_health_failed',
          properties: <String, dynamic>{
            'error_message': result.exceptionOrNull?.message ?? 'Unknown error',
          },
        );
        _showErrorMessage(
          'Apple Health 데이터 가져오기 실패: ${result.exceptionOrNull?.message}',
        );
      }
    } catch (e) {
      // Apple Health 동기화 예외 이벤트
      AmplitudeAnalytics.logEvent(
        'workout_sync_apple_health_exception',
        properties: <String, dynamic>{'error_message': e.toString()},
      );
      _showErrorMessage('Apple Health 데이터 가져오기 중 오류 발생: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Health Connect에서 데이터 가져오기 (초기화 + 연결 + 동기화)
  Future<void> _syncHealthConnectData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final TerraHealthSyncFacade facade = ref.read(
        terraHealthSyncFacadeProvider,
      );
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
          _showInfoMessage('Health Connect 데이터 가져오기 완료! 웹훅을 통해 데이터가 전송됩니다.');
        } else {
          // Health Connect 동기화 성공 (직접) 이벤트
          AmplitudeAnalytics.logEvent(
            'workout_sync_health_connect_success',
            properties: <String, dynamic>{
              'sync_method': 'direct',
              'data_count': data?.length ?? 0,
            },
          );
          _showSuccessMessage('Health Connect 데이터 가져오기 완료!');
        }
      } else {
        // Health Connect 동기화 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'workout_sync_health_connect_failed',
          properties: <String, dynamic>{
            'error_message': result.exceptionOrNull?.message ?? 'Unknown error',
          },
        );
        _showErrorMessage(
          'Health Connect 데이터 가져오기 실패: ${result.exceptionOrNull?.message}',
        );
      }
    } catch (e) {
      // Health Connect 동기화 예외 이벤트
      AmplitudeAnalytics.logEvent(
        'workout_sync_health_connect_exception',
        properties: <String, dynamic>{'error_message': e.toString()},
      );
      _showErrorMessage('Health Connect 데이터 가져오기 중 오류 발생: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Samsung Health에서 데이터 가져오기 (초기화 + 연결 + 동기화)
  Future<void> _syncSamsungHealthData() async {
    // Samsung Health 동기화 버튼 클릭 이벤트
    AmplitudeAnalytics.logButtonClick('workout_sync_samsung_health');

    setState(() {
      _isLoading = true;
    });

    try {
      final TerraHealthSyncFacade facade = ref.read(
        terraHealthSyncFacadeProvider,
      );
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
          _showInfoMessage('Samsung Health 데이터 가져오기 완료! 웹훅을 통해 데이터가 전송됩니다.');
        } else {
          // Samsung Health 동기화 성공 (직접) 이벤트
          AmplitudeAnalytics.logEvent(
            'workout_sync_samsung_health_success',
            properties: <String, dynamic>{
              'sync_method': 'direct',
              'data_count': data?.length ?? 0,
            },
          );
          _showSuccessMessage('Samsung Health 데이터 가져오기 완료!');
        }
      } else {
        // Samsung Health 동기화 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'workout_sync_samsung_health_failed',
          properties: <String, dynamic>{
            'error_message': result.exceptionOrNull?.message ?? 'Unknown error',
          },
        );
        _showErrorMessage(
          'Samsung Health 데이터 가져오기 실패: ${result.exceptionOrNull?.message}',
        );
      }
    } catch (e) {
      // Samsung Health 동기화 예외 이벤트
      AmplitudeAnalytics.logEvent(
        'workout_sync_samsung_health_exception',
        properties: <String, dynamic>{'error_message': e.toString()},
      );
      _showErrorMessage('Samsung Health 데이터 가져오기 중 오류 발생: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showInfoMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.blue),
      );
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
                child: ButtonOutlined(
                  text: _isLoading ? '동기화 중...' : 'Apple Health Kit 동기화',
                  textColor: colors.labelNormal,
                  borderColor: colors.lineNormalNormal,
                  onPressed: _isLoading ? null : _syncAppleHealthKit,
                ),
              ),

              const SizedBox(height: 16),

              // Google Health Connect 섹션
              SizedBox(
                width: double.infinity,
                child: ButtonOutlined(
                  text: _isLoading ? '동기화 중...' : 'Google Health Connect 동기화',
                  textColor: colors.labelNormal,
                  borderColor: colors.lineNormalNormal,
                  onPressed: _isLoading ? null : _syncGoogleHealthConnect,
                ),
              ),

              const SizedBox(height: 16),

              // Garmin Connect 섹션
              SizedBox(
                width: double.infinity,
                child: ButtonOutlined(
                  text: _isLoading ? '동기화 중...' : 'Garmin Connect 동기화',
                  textColor: colors.labelNormal,
                  borderColor: colors.lineNormalNormal,
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            // Garmin Connect 동기화 버튼 클릭 이벤트 (지원하지 않음)
                            AmplitudeAnalytics.logButtonClick(
                              'workout_sync_garmin_connect',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Garmin Connect는 Terra API에서 지원하지 않습니다.',
                                ),
                              ),
                            );
                          },
                ),
              ),

              const SizedBox(height: 16),

              // Samsung Health 섹션
              SizedBox(
                width: double.infinity,
                child: ButtonOutlined(
                  text: _isLoading ? '동기화 중...' : 'Samsung Health 동기화',
                  textColor: colors.labelNormal,
                  borderColor: colors.lineNormalNormal,
                  onPressed: _isLoading ? null : _syncSamsungHealthData,
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
