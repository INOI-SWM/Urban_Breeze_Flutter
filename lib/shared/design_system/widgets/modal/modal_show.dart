import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:urban_breeze/shared/design_system/widgets/modal/modal_popup.dart';

class ModalShow {
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
    VoidCallback? onSecondaryButtonPressed,
    bool showCloseButton = true,
    VoidCallback? onClose,
    bool barrierDismissible = true,
    ValueListenable<bool>? primaryEnabledListenable,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext) {
        return ModalPopup(
          title: title,
          content: content,
          primaryButtonText: primaryButtonText,
          secondaryButtonText: secondaryButtonText,
          onPrimaryButtonPressed: onPrimaryButtonPressed,
          onSecondaryButtonPressed: onSecondaryButtonPressed,
          showCloseButton: showCloseButton,
          onClose: onClose,
          primaryEnabledListenable: primaryEnabledListenable,
        );
      },
    );
  }
}
