import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/app_theme.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/design_system/modal/modal.dart';

class ModalShow {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
    VoidCallback? onSecondaryButtonPressed,
    bool showCloseButton = true,
    VoidCallback? onClose,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext) {
        //todo: 추후 상태관리 툴 도입하면 구조변경
        return SemanticTheme(
          data: context.semanticColor,
          child: Modal(
            title: title,
            content: content,
            primaryButtonText: primaryButtonText,
            secondaryButtonText: secondaryButtonText,
            onPrimaryButtonPressed: onPrimaryButtonPressed,
            onSecondaryButtonPressed: onSecondaryButtonPressed,
            showCloseButton: showCloseButton,
            onClose: onClose,
          ),
        );
      },
    );
  }
}
