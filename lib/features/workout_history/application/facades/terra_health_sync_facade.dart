import 'package:terra_flutter_bridge/models/enums.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/connect_terra_health_app_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/initialize_terra_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/sync_terra_health_data_use_case.dart';

class TerraHealthSyncFacade {
  const TerraHealthSyncFacade({
    required this.initializeTerraUseCase,
    required this.connectTerraHealthAppUseCase,
    required this.syncTerraHealthDataUseCase,
  });

  final InitializeTerraUseCase initializeTerraUseCase;
  final ConnectTerraHealthAppUseCase connectTerraHealthAppUseCase;
  final SyncTerraHealthDataUseCase syncTerraHealthDataUseCase;

  /// Terra 헬스 앱 연결 (초기화 + 권한 요청 + 권한 검증)
  Future<AppResult<void>> connectHealthApp({
    required Connection connection,
  }) async {
    try {
      // 1. Terra 초기화
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

      // 2. Terra SDK 연결 (권한 요청 + getGivenPermissions로 검증)
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

  /// Terra 헬스 앱 연결 + 데이터 가져오기 (전체 플로우, 처음 연동 시 사용)
  Future<AppResult<Map<String, dynamic>?>> connectAndFetchHealthData({
    required Connection connection,
    DateTime? startDate,
    DateTime? endDate,
    bool toWebhook = true,
  }) async {
    try {
      // 1. 연결 (초기화 + 권한 요청)
      final AppResult<void> connectResult = await connectHealthApp(
        connection: connection,
      );
      if (!connectResult.isSuccess) {
        return AppFailure<Map<String, dynamic>?>(
          connectResult.exceptionOrNull!,
        );
      }

      // 2. 데이터 가져오기
      return await getHealthData(
        connection: connection,
        startDate: startDate,
        endDate: endDate,
        toWebhook: toWebhook,
      );
    } catch (e) {
      AmplitudeAnalytics.logEvent(
        'terra_connect_and_fetch_exception',
        properties: <String, dynamic>{
          'connection': connection.name,
          'error_message': e.toString(),
        },
      );
      return AppFailure<Map<String, dynamic>?>(
        IntegrationException(e.toString()),
      );
    }
  }

  /// Terra 헬스 데이터 가져오기 (이미 연동된 상태에서만 사용)
  Future<AppResult<Map<String, dynamic>?>> getHealthData({
    required Connection connection,
    DateTime? startDate,
    DateTime? endDate,
    bool toWebhook = true,
  }) async {
    try {
      final AppResult<Map<String, dynamic>?> result =
          await syncTerraHealthDataUseCase.execute(
            connection: connection,
            startDate:
                startDate ?? DateTime.now().subtract(const Duration(days: 30)),
            endDate: endDate ?? DateTime.now(),
            toWebhook: toWebhook,
          );

      if (result.isSuccess) {
        AmplitudeAnalytics.logEvent(
          'terra_data_fetch_success',
          properties: <String, dynamic>{'connection': connection.name},
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
