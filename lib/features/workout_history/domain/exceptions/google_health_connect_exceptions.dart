import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';

/// Google Health Connect 권한 관련 오류
class GoogleHealthConnectPermissionException extends BaseDomainException {
  const GoogleHealthConnectPermissionException(super.message, [super.code]);
}

/// Google Health Connect 데이터 관련 오류
class GoogleHealthConnectException extends BaseDomainException {
  const GoogleHealthConnectException(super.message, [super.code]);
}

/// Google Health Connect에서 운동 기록을 찾을 수 없을 때
class GoogleHealthConnectWorkoutNotFoundException extends BaseDomainException {
  const GoogleHealthConnectWorkoutNotFoundException(
    super.message, [
    super.code,
  ]);
}

/// Google Health Connect가 사용 불가능할 때
class GoogleHealthConnectUnavailableException extends BaseDomainException {
  const GoogleHealthConnectUnavailableException(super.message, [super.code]);
}
