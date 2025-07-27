import 'package:ridingmate/shared/domain/exceptions/base_domain_exception.dart';

/// Apple HealthKit 권한 관련 오류
class HealthKitPermissionException extends BaseDomainException {
  const HealthKitPermissionException(super.message, [super.code]);
}

/// Apple HealthKit 데이터 관련 오류
class HealthKitDataException extends BaseDomainException {
  const HealthKitDataException(super.message, [super.code]);
}

/// Apple HealthKit에서 운동 기록을 찾을 수 없을 때
class HealthKitWorkoutNotFoundException extends BaseDomainException {
  const HealthKitWorkoutNotFoundException(super.message, [super.code]);
}
