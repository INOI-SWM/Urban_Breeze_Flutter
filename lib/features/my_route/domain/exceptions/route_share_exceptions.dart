import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';

/// 경로 공유 관련 도메인 예외
class RouteShareException extends BaseDomainException {
  const RouteShareException({required String message, required String code})
    : super(message, code);
}

/// 경로를 찾을 수 없는 예외 (404)
class RouteNotFoundException extends RouteShareException {
  const RouteNotFoundException()
    : super(message: '경로를 찾을 수 없습니다', code: 'ROUTE_NOT_FOUND');
}

/// 이미 추가된 경로 예외 (409)
class RouteAlreadyAddedException extends RouteShareException {
  const RouteAlreadyAddedException()
    : super(message: '이미 추가된 경로입니다', code: 'ROUTE_ALREADY_ADDED');
}

/// 경로 접근 거부 예외 (403)
class RouteAccessDeniedException extends RouteShareException {
  const RouteAccessDeniedException()
    : super(message: '접근이 거부되었습니다', code: 'ROUTE_ACCESS_DENIED');
}
