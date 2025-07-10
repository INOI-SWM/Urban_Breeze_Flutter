abstract class PlaceSearchDomainException implements Exception {
  const PlaceSearchDomainException(this.message);
  final String message;

  @override
  String toString() => 'PlaceSearchDomainException: $message';
}

/// 검색어가 비어있거나 유효하지 않을 때
class EmptyQueryException extends PlaceSearchDomainException {
  const EmptyQueryException(super.message);

  @override
  String toString() => 'EmptyQueryException: $message';
}

/// 검색 결과가 없을 때
class NoResultsException extends PlaceSearchDomainException {
  const NoResultsException(super.message);

  @override
  String toString() => 'NoResultsException: $message';
}

/// 네트워크 문제
class PlaceSearchNetworkException extends PlaceSearchDomainException {
  const PlaceSearchNetworkException(super.message);

  @override
  String toString() => 'PlaceSearchNetworkException: $message';
}

/// 서버 문제
class PlaceSearchServerException extends PlaceSearchDomainException {
  const PlaceSearchServerException(super.message);

  @override
  String toString() => 'PlaceSearchServerException: $message';
}

/// 데이터 파싱 문제
class PlaceSearchParsingException extends PlaceSearchDomainException {
  const PlaceSearchParsingException(super.message);

  @override
  String toString() => 'PlaceSearchParsingException: $message';
}
