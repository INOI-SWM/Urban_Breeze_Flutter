import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';

/// Integration 관련 예외
class IntegrationException extends BaseDomainException {
  const IntegrationException(super.message);
}

/// API 할당량 초과 예외
class IntegrationQuotaExceededException extends IntegrationException {
  const IntegrationQuotaExceededException(super.message);
}

/// 동기화 작업을 찾을 수 없음 (404)
class SyncJobNotFoundException extends IntegrationException {
  const SyncJobNotFoundException(super.message);
}
