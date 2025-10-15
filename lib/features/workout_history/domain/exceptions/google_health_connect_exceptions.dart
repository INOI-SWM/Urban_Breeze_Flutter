import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';

/// Google Health Connect 권한 관련 오류
class GoogleHealthConnectPermissionException extends BaseDomainException {
  const GoogleHealthConnectPermissionException(super.message, [super.code]);
}

/// Google Health Connect 권한 거부 오류
class GoogleHealthConnectPermissionDeniedException extends BaseDomainException {
  const GoogleHealthConnectPermissionDeniedException()
    : super('사용자가 권한을 거부했습니다', 'PERMISSION_DENIED');
}

/// Google Health Connect 사용 불가 오류
class GoogleHealthConnectNotAvailableException extends BaseDomainException {
  const GoogleHealthConnectNotAvailableException()
    : super('Health Connect를 사용할 수 없습니다', 'NOT_AVAILABLE');
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
