import 'package:urban_breeze/features/workout_history/data/models/integration_authentication_response_model.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/integration_authentication.dart';

/// 연동 인증 매퍼
class IntegrationAuthenticationMapper {
  const IntegrationAuthenticationMapper._();

  /// 응답 모델을 도메인 엔티티로 변환
  static IntegrationAuthentication fromResponseModel(
    IntegrationAuthenticationResponseModel model,
  ) {
    return IntegrationAuthentication(url: model.url);
  }
}
