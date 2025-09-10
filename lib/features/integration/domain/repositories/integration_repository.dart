import 'package:urban_breeze/features/integration/domain/entities/integration_auth.dart';

/// 연동 Repository 인터페이스
abstract class IntegrationRepository {
  /// 연동 링크 요청
  Future<IntegrationAuth> requestIntegrationLink({
    required String terraProvider,
  });

  /// 연동된 서비스들의 활동 기록 가져오기
  Future<Map<String, dynamic>> getIntegrationActivity();
}
