import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/button/button_outlined.dart';
import 'package:ridingmate/design_system/button/button_size.dart';
import 'package:ridingmate/design_system/button/button_solid.dart';
import 'package:ridingmate/design_system/navigation/top_navigation_bar.dart';

class ModalPopup extends StatelessWidget {
  const ModalPopup({
    super.key,
    this.title,
    required this.content,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.showCloseButton = true,
    this.onClose,
  });

  final String? title;
  final Widget content;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final bool showCloseButton;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: screenWidth,
        decoration: BoxDecoration(
          color: colors.backgroundNormalNormal,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TopNavigationBar(
              title: title,
              actions:
                  showCloseButton
                      ? <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            onClose?.call();
                          },
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: Icon(
                              Icons.close,
                              size: 24,
                              color: colors.labelNeutral,
                            ),
                          ),
                        ),
                      ]
                      : null,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: content,
              ),
            ),
            if (primaryButtonText != null || secondaryButtonText != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    if (secondaryButtonText != null)
                      Expanded(
                        child: ButtonOutlined(
                          text: secondaryButtonText!,
                          textColor: colors.labelNormal,
                          borderColor: colors.lineNormalNeutral,
                          size: ButtonSize.large,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onSecondaryButtonPressed?.call();
                          },
                        ),
                      ),
                    if (secondaryButtonText != null &&
                        primaryButtonText != null)
                      const SizedBox(width: 12),
                    if (primaryButtonText != null)
                      Expanded(
                        child: ButtonSolid(
                          text: primaryButtonText!,
                          textColor: colors.staticWhite,
                          backgroundColor: colors.primaryNormal,
                          size: ButtonSize.large,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onPrimaryButtonPressed?.call();
                          },
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
