import 'package:ridingmate/shared/domain/exceptions/base_domain_exception.dart';

sealed class AppResult<T> {
  const AppResult();

  bool get isSuccess => this is AppSuccess<T>;

  bool get isFailure => this is AppFailure<T>;

  T? get dataOrNull => switch (this) {
    AppSuccess<T>(:final T data) => data,
    AppFailure<T>() => null,
  };

  BaseDomainException? get exceptionOrNull => switch (this) {
    AppSuccess<T>() => null,
    AppFailure<T>(:final BaseDomainException exception) => exception,
  };
}

class AppSuccess<T> extends AppResult<T> {
  const AppSuccess(this.data);
  final T data;
}

class AppFailure<T> extends AppResult<T> {
  const AppFailure(this.exception);
  final BaseDomainException exception;

  String get message => exception.message;
  String? get code => exception.code;
}
