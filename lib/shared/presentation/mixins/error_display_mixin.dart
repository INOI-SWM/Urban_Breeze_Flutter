import 'package:flutter/material.dart';
import 'package:ridingmate/shared/core/result/app_result.dart';
import 'package:ridingmate/shared/domain/exceptions/base_domain_exception.dart';
import 'package:ridingmate/shared/presentation/utils/error_message_mapper.dart';

mixin ErrorDisplayMixin {
  void showErrorMessage(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void showErrorFromException(
    BuildContext context,
    BaseDomainException exception,
  ) {
    showErrorMessage(context, _getErrorMessage(exception));
  }

  void showErrorFromAppResult<T>(BuildContext context, AppFailure<T> failure) {
    showErrorFromException(context, failure.exception);
  }

  void showSuccessMessage(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  String _getErrorMessage(BaseDomainException exception) {
    return ErrorMessageMapper.getErrorMessage(exception);
  }
}
