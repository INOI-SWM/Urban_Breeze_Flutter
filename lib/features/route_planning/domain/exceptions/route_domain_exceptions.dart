abstract class RouteDomainException implements Exception {
  const RouteDomainException(this.message);
  final String message;

  @override
  String toString() => 'RouteDomainException: $message';
}

/// 네트워크 문제
class RouteNetworkException extends RouteDomainException {
  const RouteNetworkException(super.message);

  @override
  String toString() => 'RouteNetworkException: $message';
}

/// 서버 문제
class RouteServerException extends RouteDomainException {
  const RouteServerException(super.message);

  @override
  String toString() => 'RouteServerException: $message';
}

/// 데이터 파싱 문제
class RouteParsingException extends RouteDomainException {
  const RouteParsingException(super.message);

  @override
  String toString() => 'RouteParsingException: $message';
}

/// 경로 유효성 검증 문제
class RouteValidationException extends RouteDomainException {
  const RouteValidationException(super.message);

  @override
  String toString() => 'RouteValidationException: $message';
}

class InvalidBboxException extends RouteDomainException {
  const InvalidBboxException(super.message);

  @override
  String toString() => 'InvalidBboxException: $message';
}

class RouteSaveException extends RouteDomainException {
  const RouteSaveException(super.message);

  @override
  String toString() => 'RouteSaveException: $message';
}
