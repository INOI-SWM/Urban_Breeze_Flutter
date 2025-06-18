abstract class RouteException implements Exception {
  const RouteException(this.message);
  final String message;

  @override
  String toString() => 'RouteException: $message';
}

class RouteNetworkException extends RouteException {
  const RouteNetworkException(super.message);

  @override
  String toString() => 'RouteNetworkException: $message';
}

class RouteParsingException extends RouteException {
  const RouteParsingException(super.message);

  @override
  String toString() => 'RouteParsingException: $message';
}

class RouteValidationException extends RouteException {
  const RouteValidationException(super.message);

  @override
  String toString() => 'RouteValidationException: $message';
}
