import 'package:ridingmate/shared/domain/exceptions/base_domain_exception.dart';

/// 검색어가 비어있거나 유효하지 않을 때
class EmptyQueryException extends BaseDomainException {
  const EmptyQueryException(super.message, [super.code]);
}

/// 검색 결과가 없을 때
class NoResultsException extends BaseDomainException {
  const NoResultsException(super.message, [super.code]);
}
