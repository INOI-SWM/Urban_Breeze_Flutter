import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';

/// 통합 연동(Integration) 관련 기본 예외
class IntegrationException extends BaseDomainException {
  const IntegrationException(super.message, [super.code]);
}

/// 연동 인증 실패 예외
class IntegrationAuthException extends BaseDomainException {
  const IntegrationAuthException(super.message, [super.code]);
}

/// 연동 동기화 실패 예외
class IntegrationSyncException extends BaseDomainException {
  const IntegrationSyncException(super.message, [super.code]);
}

/// 연동 API 사용량 초과 예외
class IntegrationQuotaExceededException extends BaseDomainException {
  const IntegrationQuotaExceededException(super.message, [super.code]);
}

/// 연동 Provider 관련 예외
class IntegrationProviderException extends BaseDomainException {
  const IntegrationProviderException(super.message, [super.code]);
}
