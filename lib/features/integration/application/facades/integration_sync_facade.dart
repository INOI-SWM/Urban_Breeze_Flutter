import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/application/use_cases/get_integration_activity_use_case.dart';

class IntegrationSyncFacade {
  const IntegrationSyncFacade({required this.getIntegrationActivityUseCase});

  final GetIntegrationActivityUseCase getIntegrationActivityUseCase;

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
      return AppFailure<Map<String, dynamic>>(
        IntegrationException(e.toString()),
      );
    }
  }
}
