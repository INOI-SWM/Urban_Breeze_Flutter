import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';

/// 운동기록 제목 업데이트 실패 시
class WorkoutTitleUpdateException extends BaseDomainException {
  const WorkoutTitleUpdateException(super.message, [super.code]);
}

/// Terra API 관련 예외
class TerraApiException extends BaseDomainException {
  const TerraApiException(super.message, [super.code]);
}

/// 동기화 사용량 초과 예외
class WorkoutSyncQuotaExceededException extends BaseDomainException {
  const WorkoutSyncQuotaExceededException(super.message, [super.code]);
}
