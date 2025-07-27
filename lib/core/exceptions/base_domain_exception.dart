abstract class BaseDomainException implements Exception {
  const BaseDomainException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() =>
      '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 네트워크 관련 오류
class NetworkException extends BaseDomainException {
  const NetworkException(super.message, [super.code]);
}

/// 서버 응답 오류
class ServerException extends BaseDomainException {
  const ServerException(super.message, [super.code]);
}

/// 데이터 파싱 오류
class ParsingException extends BaseDomainException {
  const ParsingException(super.message, [super.code]);
}

/// 유효성 검증 오류
class ValidationException extends BaseDomainException {
  const ValidationException(super.message, [super.code]);
}
