import 'package:terra_flutter_bridge/models/enums.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/connect_terra_health_app_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/initialize_terra_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/sync_google_health_connect_data_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/sync_terra_health_data_use_case.dart';

class TerraHealthSyncFacade {
  const TerraHealthSyncFacade({
    required this.initializeTerraUseCase,
    required this.connectTerraHealthAppUseCase,
    required this.syncTerraHealthDataUseCase,
    required this.syncGoogleHealthConnectDataUseCase,
  });

  final InitializeTerraUseCase initializeTerraUseCase;
  final ConnectTerraHealthAppUseCase connectTerraHealthAppUseCase;
  final SyncTerraHealthDataUseCase syncTerraHealthDataUseCase;
  final SyncGoogleHealthConnectDataUseCase syncGoogleHealthConnectDataUseCase;

  /// Terra 헬스 앱 연결 (초기화 + 우리가 직접 권한 관리)
  Future<AppResult<void>> connectHealthApp({
    required Connection connection,
  }) async {
    try {
      // 1. Health Connect만 우리가 직접 권한 관리
      if (connection == Connection.healthConnect) {
        // 1-1. 권한 확인
        final bool hasPermission =
            await syncGoogleHealthConnectDataUseCase.checkPermissions();

        if (!hasPermission) {
          // 1-2. 권한 요청
          final bool granted =
              await syncGoogleHealthConnectDataUseCase.requestPermissions();

          if (!granted) {
            AmplitudeAnalytics.logEvent(
              'health_connect_permission_denied',
              properties: <String, dynamic>{'connection': connection.name},
            );
            return const AppFailure<void>(
              IntegrationException('Health Connect 권한이 거부되었습니다.'),
            );
          }
        }
      }

      // 2. Terra 초기화
      final AppResult<void> initResult = await initializeTerraUseCase.execute();
      if (!initResult.isSuccess) {
        AmplitudeAnalytics.logEvent(
          'terra_initialization_failed',
          properties: <String, dynamic>{
            'connection': connection.name,
            'error_message':
                initResult.exceptionOrNull?.toString() ?? 'Unknown error',
          },
        );
        return AppFailure<void>(initResult.exceptionOrNull!);
      }

      // 3. Terra SDK 연결 (권한은 이미 우리가 처리함)
      final AppResult<void> connectResult = await connectTerraHealthAppUseCase
          .execute(connection);
      if (!connectResult.isSuccess) {
        AmplitudeAnalytics.logEvent(
          'terra_health_app_connection_failed',
          properties: <String, dynamic>{
            'connection': connection.name,
            'error_message':
                connectResult.exceptionOrNull?.toString() ?? 'Unknown error',
          },
        );
        return AppFailure<void>(connectResult.exceptionOrNull!);
      }

      // 연결 성공
      AmplitudeAnalytics.logEvent(
        'terra_health_app_connected',
        properties: <String, dynamic>{'connection': connection.name},
      );

      return const AppSuccess<void>(null);
    } catch (e) {
      AmplitudeAnalytics.logEvent(
        'terra_connection_exception',
        properties: <String, dynamic>{
          'connection': connection.name,
          'error_message': e.toString(),
        },
      );
      return AppFailure<void>(IntegrationException(e.toString()));
    }
  }

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
      return AppFailure<Map<String, dynamic>?>(
        IntegrationException(e.toString()),
      );
    }
  }

  /// Health Connect 연결 (초기화 + 권한 요청만)
  Future<AppResult<void>> syncHealthConnectData({
    DateTime? startDate,
    DateTime? endDate,
    bool toWebhook = true,
  }) async {
    return connectHealthApp(connection: Connection.healthConnect);
  }

  /// Samsung Health 연결 (초기화 + 권한 요청만)
  Future<AppResult<void>> syncSamsungHealthData({
    DateTime? startDate,
    DateTime? endDate,
    bool toWebhook = true,
  }) async {
    return connectHealthApp(connection: Connection.samsung);
  }

  /// Health Connect 데이터 가져오기 (이미 연동된 상태에서만 사용)
  Future<AppResult<Map<String, dynamic>?>> getHealthConnectData({
    DateTime? startDate,
    DateTime? endDate,
    bool toWebhook = true,
  }) async {
    try {
      final AppResult<Map<String, dynamic>?> result =
          await syncTerraHealthDataUseCase.execute(
            connection: Connection.healthConnect,
            startDate:
                startDate ?? DateTime.now().subtract(const Duration(days: 30)),
            endDate: endDate ?? DateTime.now(),
            toWebhook: toWebhook,
          );

      if (result.isSuccess) {
        AmplitudeAnalytics.logEvent(
          'terra_data_fetch_success',
          properties: <String, dynamic>{'connection': 'healthConnect'},
        );
      }

      return result;
    } catch (e) {
      return AppFailure<Map<String, dynamic>?>(
        IntegrationException(e.toString()),
      );
    }
  }

  /// Samsung Health 데이터 가져오기 (이미 연동된 상태에서만 사용)
  Future<AppResult<Map<String, dynamic>?>> getSamsungHealthData({
    DateTime? startDate,
    DateTime? endDate,
    bool toWebhook = true,
  }) async {
    try {
      final AppResult<Map<String, dynamic>?> result =
          await syncTerraHealthDataUseCase.execute(
            connection: Connection.samsung,
            startDate:
                startDate ?? DateTime.now().subtract(const Duration(days: 30)),
            endDate: endDate ?? DateTime.now(),
            toWebhook: toWebhook,
          );

      if (result.isSuccess) {
        AmplitudeAnalytics.logEvent(
          'terra_data_fetch_success',
          properties: <String, dynamic>{'connection': 'samsung'},
        );
      }

      return result;
    } catch (e) {
      return AppFailure<Map<String, dynamic>?>(
        IntegrationException(e.toString()),
      );
    }
  }
}
