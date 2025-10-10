import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';

/// 운동기록 제목 업데이트 실패 시
class WorkoutTitleUpdateException extends BaseDomainException {
  const WorkoutTitleUpdateException(super.message, [super.code]);
}
