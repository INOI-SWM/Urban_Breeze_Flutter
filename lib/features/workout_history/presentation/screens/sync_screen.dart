import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/sync_apple_health_kit_data_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/sync_google_health_connect_data_use_case.dart';
import 'package:urban_breeze/features/workout_history/di/workout_statistics_providers.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_record.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_outlined.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';

class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  bool _isLoading = false;

  // Apple Health Kit 관련 메서드들
  Future<void> _requestAppleHealthKitPermissions() async {
    try {
      final SyncAppleHealthKitDataUseCase useCase = ref.read(
        syncAppleHealthKitDataUseCaseProvider,
      );
      await useCase.requestPermissions();
    } catch (e) {
      // TODO : 권한 요청 실패 시 에러 처리
    }
  }

  Future<void> _testGetAppleHealthKitWorkouts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final SyncAppleHealthKitDataUseCase useCase = ref.read(
        syncAppleHealthKitDataUseCaseProvider,
      );
      final List<WorkoutRecord> workouts = await useCase.fetchBasicWorkoutData(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      setState(() {
        _isLoading = false;
      });

      // TODO: 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple Health Kit 데이터 ${workouts.length}개 동기화 완료'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // TODO: 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apple Health Kit 동기화 실패')),
        );
      }
    }
  }

  // Google Health Connect 관련 메서드들
  Future<void> _requestGoogleHealthConnectPermissions() async {
    try {
      final SyncGoogleHealthConnectDataUseCase useCase = ref.read(
        syncGoogleHealthConnectDataUseCaseProvider,
      );
      await useCase.requestPermissions();
    } catch (e) {
      // TODO : 권한 요청 실패 시 에러 처리
    }
  }

  Future<void> _testGetGoogleHealthConnectWorkouts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final SyncGoogleHealthConnectDataUseCase useCase = ref.read(
        syncGoogleHealthConnectDataUseCaseProvider,
      );
      final Map<WorkoutRecord, Map<String, dynamic>> completeData =
          await useCase.syncCompleteWorkoutData(
            startDate: DateTime.now().subtract(const Duration(days: 1000)),
            endDate: DateTime.now(),
          );

      final List<WorkoutRecord> workouts = completeData.keys.toList();

      setState(() {
        _isLoading = false;
      });

      // TODO: 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Google Health Connect 데이터 ${workouts.length}개 동기화 완료',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // TODO: 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Health Connect 동기화 실패')),
        );
      }
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
              Text(
                'Health Kit 연동',
                style: AppTextStyles.title3.bold.copyWith(
                  color: colors.labelStrong,
                ),
              ),
              const SizedBox(height: 16),

              // Apple Health Kit 섹션
              Row(
                children: <Widget>[
                  Expanded(
                    child: ButtonOutlined(
                      text: 'Apple 권한 요청',
                      textColor: colors.labelNormal,
                      borderColor: colors.lineNormalNormal,
                      onPressed:
                          _isLoading ? null : _requestAppleHealthKitPermissions,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ButtonOutlined(
                      text: _isLoading ? '동기화 중...' : 'Apple 데이터 동기화',
                      textColor: colors.labelNormal,
                      borderColor: colors.lineNormalNormal,
                      onPressed:
                          _isLoading ? null : _testGetAppleHealthKitWorkouts,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Google Health Connect 섹션
              Row(
                children: <Widget>[
                  Expanded(
                    child: ButtonOutlined(
                      text: 'Google 권한 요청',
                      textColor: colors.labelNormal,
                      borderColor: colors.lineNormalNormal,
                      onPressed:
                          _isLoading
                              ? null
                              : _requestGoogleHealthConnectPermissions,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ButtonOutlined(
                      text: _isLoading ? '동기화 중...' : 'Google 데이터 동기화',
                      textColor: colors.labelNormal,
                      borderColor: colors.lineNormalNormal,
                      onPressed:
                          _isLoading
                              ? null
                              : _testGetGoogleHealthConnectWorkouts,
                    ),
                  ),
                ],
              ),

              if (_isLoading) ...<Widget>[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
