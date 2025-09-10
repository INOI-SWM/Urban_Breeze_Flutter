import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/application/use_cases/get_integration_activity_use_case.dart';
import 'package:urban_breeze/features/integration/application/use_cases/request_garmin_permission_use_case.dart';
import 'package:urban_breeze/features/integration/application/use_cases/request_suunto_permission_use_case.dart';
import 'package:urban_breeze/features/integration/domain/entities/integration_auth.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';

class IntegrationSyncFacade {
  const IntegrationSyncFacade({
    required this.requestGarminPermissionUseCase,
    required this.requestSuuntoPermissionUseCase,
    required this.getIntegrationActivityUseCase,
  });

  final RequestGarminPermissionUseCase requestGarminPermissionUseCase;
  final RequestSuuntoPermissionUseCase requestSuuntoPermissionUseCase;
  final GetIntegrationActivityUseCase getIntegrationActivityUseCase;

  /// Garmin Connect 연동 링크 요청
  Future<AppResult<IntegrationAuth>> requestGarminPermission() async {
    try {
      // Garmin Connect 연동 링크 요청
      final AppResult<IntegrationAuth> result =
          await requestGarminPermissionUseCase.execute();

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
      return AppFailure<IntegrationAuth>(TerraApiException(e.toString()));
    }
  }

  /// Suunto 연동 링크 요청
  Future<AppResult<IntegrationAuth>> requestSuuntoPermission() async {
    try {
      // Suunto 연동 링크 요청
      final AppResult<IntegrationAuth> result =
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
      return AppFailure<IntegrationAuth>(TerraApiException(e.toString()));
    }
  }

  /// 연동된 서비스들의 활동 기록 새로고침
  Future<AppResult<Map<String, dynamic>>> refreshIntegrationActivity() async {
    try {
      // 연동 활동 기록 새로고침 버튼 클릭 이벤트
      AmplitudeAnalytics.logButtonClick('workout_sync_refresh_activity');

      final AppResult<Map<String, dynamic>> result =
          await getIntegrationActivityUseCase.execute();

      if (result.isSuccess) {
        // 연동 활동 기록 새로고침 성공 이벤트
        AmplitudeAnalytics.logEvent(
          'integration_activity_refresh_success',
          properties: <String, dynamic>{},
        );
        return result;
      } else {
        // 연동 활동 기록 새로고침 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'integration_activity_refresh_failed',
          properties: <String, dynamic>{
            'error_message':
                result.exceptionOrNull?.toString() ?? 'Unknown error',
          },
        );
        return result;
      }
    } catch (e) {
      // 연동 활동 기록 새로고침 예외 이벤트
      AmplitudeAnalytics.logEvent(
        'integration_activity_refresh_exception',
        properties: <String, dynamic>{'error_message': e.toString()},
      );
      return AppFailure<Map<String, dynamic>>(TerraApiException(e.toString()));
    }
  }
}
