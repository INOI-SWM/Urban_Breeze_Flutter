abstract class PlaceSearchException implements Exception {
  const PlaceSearchException(this.message);

  final String message;

  @override
  String toString() => 'PlaceSearchException: $message';
}

class NetworkException extends PlaceSearchException {
  const NetworkException([super.message = '네트워크 연결을 확인해주세요']);
}

class ApiException extends PlaceSearchException {
  const ApiException(this.statusCode, [String? message])
    : super(message ?? 'API 요청 중 오류가 발생했습니다');

  final int statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ParseException extends PlaceSearchException {
  const ParseException([super.message = '응답 데이터 처리 중 오류가 발생했습니다']);
}

class NoResultsException extends PlaceSearchException {
  const NoResultsException([super.message = '검색 결과가 없습니다']);
}
