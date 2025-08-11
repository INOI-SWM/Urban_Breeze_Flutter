import 'package:ridingmate/core/exceptions/base_domain_exception.dart';

/// 사용자가 로그인 플로우를 취소했거나, 프로바이더 로그인에 실패한 경우
class AuthCanceledException extends BaseDomainException {
  const AuthCanceledException([String message = '로그인이 취소되었거나 실패했습니다'])
    : super(message, 'AUTH_CANCELED');
}

/// 소셜 자격증명(idToken/accessToken 등) 획득 실패
class AuthCredentialMissingException extends BaseDomainException {
  const AuthCredentialMissingException([String message = '자격증명 획득에 실패했습니다'])
    : super(message, 'AUTH_CREDENTIAL_MISSING');
}

/// 자격증명을 서버로 교환하는 과정에서 실패
class AuthExchangeFailedException extends BaseDomainException {
  const AuthExchangeFailedException([String message = '로그인 처리 중 오류가 발생했습니다'])
    : super(message, 'AUTH_EXCHANGE_FAILED');
}
