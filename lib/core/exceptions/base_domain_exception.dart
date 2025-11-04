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

/// 로컬 저장소 관련 오류
class LocalStorageException extends BaseDomainException {
  const LocalStorageException(super.message, [super.code]);
}
