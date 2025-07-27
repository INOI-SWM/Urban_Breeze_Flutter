import 'package:ridingmate/shared/domain/exceptions/base_domain_exception.dart';

/// 경로의 Bounding Box가 유효하지 않을 때
class InvalidBboxException extends BaseDomainException {
  const InvalidBboxException(super.message, [super.code]);
}

/// 경로 저장 실패 시
class RouteSaveException extends BaseDomainException {
  const RouteSaveException(super.message, [super.code]);
}
