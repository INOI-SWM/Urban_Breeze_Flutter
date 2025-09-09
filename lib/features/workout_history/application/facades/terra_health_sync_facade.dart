import 'package:terra_flutter_bridge/models/enums.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/connect_terra_health_app_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/initialize_terra_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/request_garmin_connect_permission_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/request_suunto_permission_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/sync_terra_health_data_use_case.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';

class TerraHealthSyncFacade {
  const TerraHealthSyncFacade({
    required this.initializeTerraUseCase,
    required this.connectTerraHealthAppUseCase,
    required this.syncTerraHealthDataUseCase,
    required this.requestGarminConnectPermissionUseCase,
    required this.requestSuuntoPermissionUseCase,
  });

  final InitializeTerraUseCase initializeTerraUseCase;
  final ConnectTerraHealthAppUseCase connectTerraHealthAppUseCase;
  final SyncTerraHealthDataUseCase syncTerraHealthDataUseCase;
  final RequestGarminConnectPermissionUseCase
  requestGarminConnectPermissionUseCase;
  final RequestSuuntoPermissionUseCase requestSuuntoPermissionUseCase;

  /// Terra를 통한 건강 데이터 가져오기 (초기화 + 연결 + 동기화)
  Future<AppResult<Map<String, dynamic>?>> syncHealthDataFromTerra({
    required Connection connection,
    required DateTime startDate,
    required DateTime endDate,
    bool toWebhook = true,
  }) async {
    try {
      // 1. Terra 초기화
      final AppResult<void> initResult = await initializeTerraUseCase.execute();
      if (!initResult.isSuccess) {
        // Terra 초기화 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'terra_initialization_failed',
          properties: <String, dynamic>{
            'connection': connection.name,
            'error_message':
                initResult.exceptionOrNull?.toString() ?? 'Unknown error',
          },
        );
        return AppFailure<Map<String, dynamic>?>(initResult.exceptionOrNull!);
      }

      // 2. 건강 앱 연결
      final AppResult<void> connectResult = await connectTerraHealthAppUseCase
          .execute(connection);
      if (!connectResult.isSuccess) {
        // 건강 앱 연결 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'terra_health_app_connection_failed',
          properties: <String, dynamic>{
            'connection': connection.name,
            'error_message':
                connectResult.exceptionOrNull?.toString() ?? 'Unknown error',
          },
        );
        return AppFailure<Map<String, dynamic>?>(
          connectResult.exceptionOrNull!,
        );
      }

      // 3. 데이터 동기화
      final AppResult<Map<String, dynamic>?> syncResult =
          await syncTerraHealthDataUseCase.execute(
            connection: connection,
            startDate: startDate,
            endDate: endDate,
            toWebhook: toWebhook,
          );

      if (syncResult.isSuccess) {
        // Terra 동기화 성공 이벤트
        AmplitudeAnalytics.logEvent(
          'terra_sync_success',
          properties: <String, dynamic>{
            'connection': connection.name,
            'to_webhook': toWebhook,
          },
        );
      } else {
        // Terra 동기화 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'terra_sync_failed',
          properties: <String, dynamic>{
            'connection': connection.name,
            'to_webhook': toWebhook,
            'error_message':
                syncResult.exceptionOrNull?.toString() ?? 'Unknown error',
          },
        );
      }

      return syncResult;
    } catch (e) {
      // Terra 동기화 예외 이벤트
      AmplitudeAnalytics.logEvent(
        'terra_sync_exception',
        properties: <String, dynamic>{
          'connection': connection.name,
          'to_webhook': toWebhook,
          'error_message': e.toString(),
        },
      );
      return AppFailure<Map<String, dynamic>?>(TerraApiException(e.toString()));
    }
  }

  /// Apple Health에서 데이터 가져오기
  /// TODO: apple의 경우 데이터 가져오기 최적화 작업 진행해야함.
  Future<AppResult<Map<String, dynamic>?>> syncAppleHealthData({
    DateTime? startDate,
    DateTime? endDate,
    bool toWebhook = true,
  }) async {
    return syncHealthDataFromTerra(
      connection: Connection.appleHealth,
      startDate: startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      endDate: endDate ?? DateTime.now(),
      toWebhook: toWebhook,
    );
  }

  // googl samasung은 30일 이상 데이터 가져오기 불가능
  /// Health Connect에서 데이터 가져오기
  Future<AppResult<Map<String, dynamic>?>> syncHealthConnectData({
    DateTime? startDate,
    DateTime? endDate,
    bool toWebhook = true,
  }) async {
    return syncHealthDataFromTerra(
      connection: Connection.healthConnect,
      startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      endDate: endDate ?? DateTime.now(),
      toWebhook: toWebhook,
    );
  }

  /// Samsung Health에서 데이터 가져오기
  Future<AppResult<Map<String, dynamic>?>> syncSamsungHealthData({
    DateTime? startDate,
    DateTime? endDate,
    bool toWebhook = true,
  }) async {
    return syncHealthDataFromTerra(
      connection: Connection.samsung,
      startDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      endDate: endDate ?? DateTime.now(),
      toWebhook: toWebhook,
    );
  }

  /// Garmin Connect 연동 링크 요청
  Future<AppResult<Map<String, dynamic>>>
  requestGarminConnectPermission() async {
    try {
      // Garmin Connect 연동 링크 요청
      final AppResult<Map<String, dynamic>> result =
          await requestGarminConnectPermissionUseCase.execute();

      if (result.isSuccess) {
        // Garmin Connect 연동 링크 요청 성공 이벤트
        AmplitudeAnalytics.logEvent(
          'garmin_connect_permission_request_success',
          properties: <String, dynamic>{},
        );
        return result;
      } else {
        // Garmin Connect 연동 링크 요청 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'garmin_connect_permission_request_failed',
          properties: <String, dynamic>{
            'error_message':
                result.exceptionOrNull?.toString() ?? 'Unknown error',
          },
        );
        return result;
      }
    } catch (e) {
      // Garmin Connect 연동 링크 요청 예외 이벤트
      AmplitudeAnalytics.logEvent(
        'garmin_connect_permission_request_exception',
        properties: <String, dynamic>{'error_message': e.toString()},
      );
      return AppFailure<Map<String, dynamic>>(TerraApiException(e.toString()));
    }
  }

  /// Suunto 연동 링크 요청
  Future<AppResult<Map<String, dynamic>>> requestSuuntoPermission() async {
    try {
      // Suunto 연동 링크 요청
      final AppResult<Map<String, dynamic>> result =
          await requestSuuntoPermissionUseCase.execute();

      if (result.isSuccess) {
        // Suunto 연동 링크 요청 성공 이벤트
        AmplitudeAnalytics.logEvent(
          'suunto_permission_request_success',
          properties: <String, dynamic>{},
        );
        return result;
      } else {
        // Suunto 연동 링크 요청 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'suunto_permission_request_failed',
          properties: <String, dynamic>{
            'error_message':
                result.exceptionOrNull?.toString() ?? 'Unknown error',
          },
        );
        return result;
      }
    } catch (e) {
      // Suunto 연동 링크 요청 예외 이벤트
      AmplitudeAnalytics.logEvent(
        'suunto_permission_request_exception',
        properties: <String, dynamic>{'error_message': e.toString()},
      );
      return AppFailure<Map<String, dynamic>>(TerraApiException(e.toString()));
    }
  }
}
