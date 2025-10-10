import 'dart:io';

import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/application/facades/integration_sync_facade.dart';
import 'package:urban_breeze/features/integration/application/use_cases/get_integration_status_use_case.dart';
import 'package:urban_breeze/features/integration/domain/entities/api_usage.dart';
import 'package:urban_breeze/features/integration/domain/entities/integration_auth.dart';
import 'package:urban_breeze/features/workout_history/application/facades/terra_health_sync_facade.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/import_apple_health_workouts_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/sync_apple_health_kit_data_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/sync_google_health_connect_data_use_case.dart';
import 'package:urban_breeze/features/workout_history/data/models/apple_health_workout_model.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/heart_rate_data.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/location_data.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_record.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/apple_health_kit_exceptions.dart';

/// 워크아웃 동기화 통합 Facade
/// Terra API와 Integration API를 모두 관리
class WorkoutSyncFacade {
  const WorkoutSyncFacade({
    required this.terraHealthSyncFacade,
    required this.integrationSyncFacade,
    required this.syncAppleHealthKitDataUseCase,
    required this.syncGoogleHealthConnectDataUseCase,
    required this.importAppleHealthWorkoutsUseCase,
    required this.getIntegrationStatusUseCase,
  });

  final TerraHealthSyncFacade terraHealthSyncFacade;
  final IntegrationSyncFacade integrationSyncFacade;
  final SyncAppleHealthKitDataUseCase syncAppleHealthKitDataUseCase;
  final SyncGoogleHealthConnectDataUseCase syncGoogleHealthConnectDataUseCase;
  final ImportAppleHealthWorkoutsUseCase importAppleHealthWorkoutsUseCase;
  final GetIntegrationStatusUseCase getIntegrationStatusUseCase;

  /// Apple Health에서 데이터 가져오기 (health_kit_reporter 직접 사용)
  Future<AppResult<Map<String, dynamic>?>> syncAppleHealthData({
    DateTime? startDate,
    DateTime? endDate,
    bool toWebhook = true,
  }) async {
    try {
      // 1. API 사용량 체크
      final AppResult<ApiUsage> usageResult =
          await getIntegrationStatusUseCase.executeWithApiUsage();

      if (usageResult.isSuccess) {
        final ApiUsage apiUsage = usageResult.dataOrNull!;
        if (apiUsage.remainingUsage <= 0 || apiUsage.isExceeded) {
          AmplitudeAnalytics.logEvent(
            'apple_health_kit_sync_quota_exceeded',
            properties: <String, dynamic>{
              'remaining_usage': apiUsage.remainingUsage,
              'monthly_limit': apiUsage.monthlyLimit,
            },
          );
          return const AppFailure<Map<String, dynamic>?>(
            IntegrationQuotaExceededException(
              '이번 달 동기화 가능 횟수를 모두 사용했습니다.\n다음 달에 다시 시도해주세요.',
            ),
          );
        }
      }

      // 2. 권한 확인
      final bool hasPermission =
          await syncAppleHealthKitDataUseCase.checkPermissions();

      if (!hasPermission) {
        // 권한 요청
        final bool permissionGranted =
            await syncAppleHealthKitDataUseCase.requestPermissions();
        if (!permissionGranted) {
          // Apple Health Kit 권한 거부 이벤트
          AmplitudeAnalytics.logEvent(
            'apple_health_kit_permission_denied',
            properties: <String, dynamic>{'to_webhook': toWebhook},
          );
          return const AppFailure<Map<String, dynamic>?>(
            HealthKitPermissionException(
              'Apple Health Kit 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.',
            ),
          );
        }
      }

      // 운동 데이터 가져오기
      final List<WorkoutRecord> workouts = await syncAppleHealthKitDataUseCase
          .fetchBasicWorkoutData(
            startDate:
                startDate ?? DateTime.now().subtract(const Duration(days: 30)),
            endDate: endDate ?? DateTime.now(),
          );

      // HealthKit 데이터를 서버로 전송
      if (workouts.isNotEmpty) {
        try {
          final List<AppleHealthWorkoutModel> workoutModels =
              workouts
                  .map(
                    (WorkoutRecord workout) =>
                        _convertToAppleHealthWorkoutModel(workout),
                  )
                  .toList();

          final AppResult<void> uploadResult =
              await importAppleHealthWorkoutsUseCase.execute(
                workouts: workoutModels,
              );

          if (uploadResult.isSuccess) {
            // 서버 업로드 성공 이벤트
            AmplitudeAnalytics.logEvent(
              'apple_health_kit_server_upload_success',
              properties: <String, dynamic>{'workout_count': workouts.length},
            );
          } else {
            // 서버 업로드 실패 이벤트
            AmplitudeAnalytics.logEvent(
              'apple_health_kit_server_upload_failed',
              properties: <String, dynamic>{
                'error_message':
                    uploadResult.exceptionOrNull?.toString() ?? 'Unknown error',
              },
            );
          }
        } catch (e) {
          // 서버 업로드 예외 이벤트
          AmplitudeAnalytics.logEvent(
            'apple_health_kit_server_upload_exception',
            properties: <String, dynamic>{'error_message': e.toString()},
          );
        }
      }

      // 결과 데이터 구성
      final Map<String, dynamic> resultData = <String, dynamic>{
        'allWorkouts': workouts,
        'totalSuccess': workouts.length,
        'totalAttempts': 1,
        'noPermissionCount': 0,
        'source': 'apple_health_kit',
        'to_webhook': toWebhook,
      };

      // Apple Health Kit 동기화 성공 이벤트
      AmplitudeAnalytics.logEvent(
        'apple_health_kit_sync_success',
        properties: <String, dynamic>{'workout_count': workouts.length},
      );

      return AppSuccess<Map<String, dynamic>?>(resultData);
    } catch (e) {
      // Apple Health Kit 동기화 실패 이벤트
      AmplitudeAnalytics.logEvent(
        'apple_health_kit_sync_failed',
        properties: <String, dynamic>{'error_message': e.toString()},
      );

      return AppFailure<Map<String, dynamic>?>(
        HealthKitDataException('Apple Health Kit 동기화 실패: $e'),
      );
    }
  }

  /// Health Connect에서 데이터 가져오기
  Future<AppResult<Map<String, dynamic>?>> syncHealthConnectData({
    DateTime? startDate,
    DateTime? endDate,
    bool toWebhook = true,
  }) async {
    return terraHealthSyncFacade.syncHealthConnectData(
      startDate: startDate,
      endDate: endDate,
      toWebhook: toWebhook,
    );
  }

  /// Samsung Health에서 데이터 가져오기
  Future<AppResult<Map<String, dynamic>?>> syncSamsungHealthData({
    DateTime? startDate,
    DateTime? endDate,
    bool toWebhook = true,
  }) async {
    return terraHealthSyncFacade.syncSamsungHealthData(
      startDate: startDate,
      endDate: endDate,
      toWebhook: toWebhook,
    );
  }

  /// Garmin Connect 연동 링크 요청
  Future<AppResult<IntegrationAuth>> requestGarminPermission() async {
    return integrationSyncFacade.requestGarminPermission();
  }

  /// Suunto 연동 링크 요청
  Future<AppResult<IntegrationAuth>> requestSuuntoPermission() async {
    return integrationSyncFacade.requestSuuntoPermission();
  }

  /// 연동된 서비스들의 활동 기록 새로고침
  Future<AppResult<Map<String, dynamic>>> refreshIntegrationActivity() async {
    return integrationSyncFacade.refreshIntegrationActivity();
  }

  /// 전체 워크아웃 동기화 (Terra SDK + Integration API)
  Future<AppResult<Map<String, dynamic>>> performFullSync() async {
    try {
      final List<WorkoutRecord> allWorkouts = <WorkoutRecord>[];
      int successCount = 0;
      int totalAttempts = 0;
      int integrationSuccessCount = 0;
      int integrationTotalAttempts = 0;
      int noPermissionCount = 0; // 권한이 없는 서비스 개수

      // iOS에서만 Apple Health Kit 시도 (health_kit_reporter 직접 사용)
      if (Platform.isIOS) {
        totalAttempts++;
        try {
          // 권한 확인
          final bool hasPermission =
              await syncAppleHealthKitDataUseCase.checkPermissions();

          if (hasPermission) {
            final List<WorkoutRecord> appleWorkouts =
                await syncAppleHealthKitDataUseCase.fetchBasicWorkoutData(
                  startDate: DateTime.now().subtract(const Duration(days: 30)),
                  endDate: DateTime.now(),
                );
            allWorkouts.addAll(appleWorkouts);
            successCount++;

            // HealthKit 데이터를 서버로 전송
            if (appleWorkouts.isNotEmpty) {
              try {
                final List<AppleHealthWorkoutModel> workoutModels =
                    appleWorkouts
                        .map(
                          (WorkoutRecord workout) =>
                              _convertToAppleHealthWorkoutModel(workout),
                        )
                        .toList();

                final AppResult<void> uploadResult =
                    await importAppleHealthWorkoutsUseCase.execute(
                      workouts: workoutModels,
                    );

                if (uploadResult.isSuccess) {
                  // 서버 업로드 성공 이벤트
                  AmplitudeAnalytics.logEvent(
                    'apple_health_kit_server_upload_success',
                    properties: <String, dynamic>{
                      'workout_count': appleWorkouts.length,
                    },
                  );
                } else {
                  // 서버 업로드 실패 이벤트
                  AmplitudeAnalytics.logEvent(
                    'apple_health_kit_server_upload_failed',
                    properties: <String, dynamic>{
                      'error_message':
                          uploadResult.exceptionOrNull?.toString() ??
                          'Unknown error',
                    },
                  );
                }
              } catch (e) {
                // 서버 업로드 예외 이벤트
                AmplitudeAnalytics.logEvent(
                  'apple_health_kit_server_upload_exception',
                  properties: <String, dynamic>{'error_message': e.toString()},
                );
              }
            }

            // Apple Health Kit 동기화 성공 이벤트
            AmplitudeAnalytics.logEvent(
              'apple_health_kit_full_sync_success',
              properties: <String, dynamic>{
                'workout_count': appleWorkouts.length,
              },
            );
          } else {
            noPermissionCount++;
          }
        } catch (e) {
          // Apple Health Kit 동기화 실패 이벤트
          AmplitudeAnalytics.logEvent(
            'apple_health_kit_full_sync_failed',
            properties: <String, dynamic>{'error_message': e.toString()},
          );
        }
      }

      // Android에서만 Google Health Connect 시도
      if (Platform.isAndroid) {
        totalAttempts++;
        try {
          // 권한 확인
          final bool hasPermission =
              await syncGoogleHealthConnectDataUseCase.checkPermissions();

          if (hasPermission) {
            final Map<WorkoutRecord, Map<String, dynamic>> completeData =
                await syncGoogleHealthConnectDataUseCase
                    .syncCompleteWorkoutData(
                      startDate: DateTime.now().subtract(
                        const Duration(days: 1000),
                      ),
                      endDate: DateTime.now(),
                    );
            allWorkouts.addAll(completeData.keys.toList());
            successCount++;
          } else {
            // 권한이 없으면 카운트 증가
            noPermissionCount++;
          }
        } catch (e) {
          // Google Health Connect 오류는 카운트만 하고 상세 메시지는 표시하지 않음
        }
      }

      // 연동된 서비스들의 활동 기록 새로고침
      integrationTotalAttempts = 1; // 연동 새로고침은 항상 1번 시도
      try {
        final AppResult<Map<String, dynamic>> result =
            await integrationSyncFacade.refreshIntegrationActivity();

        if (result.isSuccess) {
          integrationSuccessCount = 1;
        }
      } catch (e) {
        // 연동 새로고침 오류는 카운트만 하고 상세 메시지는 표시하지 않음
      }

      // 결과 데이터 구성
      final Map<String, dynamic> resultData = <String, dynamic>{
        'allWorkouts': allWorkouts,
        'successCount': successCount,
        'totalAttempts': totalAttempts,
        'integrationSuccessCount': integrationSuccessCount,
        'integrationTotalAttempts': integrationTotalAttempts,
        'totalSuccess': successCount + integrationSuccessCount,
        'totalAttemptsCount': totalAttempts + integrationTotalAttempts,
        'noPermissionCount': noPermissionCount,
      };

      return AppSuccess<Map<String, dynamic>>(resultData);
    } catch (e) {
      return AppFailure<Map<String, dynamic>>(
        IntegrationException('전체 동기화 중 오류 발생: $e'),
      );
    }
  }

  /// WorkoutRecord를 AppleHealthWorkoutModel로 변환하는 헬퍼 메서드
  AppleHealthWorkoutModel _convertToAppleHealthWorkoutModel(
    WorkoutRecord workout,
  ) {
    return AppleHealthWorkoutModel(
      externalId: workout.id,
      startTime: workout.startTime.toIso8601String(),
      endTime: workout.endTime.toIso8601String(),
      duration: workout.duration.inSeconds,
      distance: workout.distance,
      calories: workout.calories,
      source: 'Apple Health',
      title: 'Cycling Workout',
      heartRateData:
          workout.heartRateData
              ?.map(
                (HeartRateData data) => HeartRateDataModel(
                  timestamp: data.timestamp.toIso8601String(),
                  heartRate: data.heartRate,
                ),
              )
              .toList() ??
          <HeartRateDataModel>[],
      locationData:
          workout.locationData
              ?.map(
                (LocationData data) => LocationDataModel(
                  latitude: data.latitude,
                  longitude: data.longitude,
                  timestamp: data.timestamp.toIso8601String(),
                  altitude: data.altitude ?? 0.0,
                  speed: data.speed ?? 0.0,
                  horizontalAccuracy: data.horizontalAccuracy ?? 0.0,
                  verticalAccuracy: data.verticalAccuracy ?? 0.0,
                  course: data.course ?? 0.0,
                ),
              )
              .toList() ??
          <LocationDataModel>[],
    );
  }
}
