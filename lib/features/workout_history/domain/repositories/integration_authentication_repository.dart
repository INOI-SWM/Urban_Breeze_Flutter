import 'package:urban_breeze/features/workout_history/domain/entities/integration_authentication.dart';

/// 연동 인증 Repository 인터페이스
abstract class IntegrationAuthenticationRepository {
  /// 연동 링크 요청
  Future<IntegrationAuthentication> requestIntegrationLink({
    required String terraProvider,
  });

  /// 연동된 서비스들의 활동 기록 가져오기
  Future<Map<String, dynamic>> getIntegrationActivity();
}
