import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';

class ValidationException extends BaseDomainException {
  const ValidationException({
    required String code,
    this.data = const <String, dynamic>{},
    String? message,
  }) : super(message ?? 'Validation failed', code);

  final Map<String, dynamic> data;

  @override
  String toString() {
    return 'ValidationException(code: $code, data: $data, message: $message)';
  }
}
