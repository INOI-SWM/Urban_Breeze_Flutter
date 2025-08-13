import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_outlined.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_size.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_solid.dart';

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
    this.primaryEnabledListenable,
  });

  final String? title;
  final Widget content;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final ValueListenable<bool>? primaryEnabledListenable;

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
            CustomAppBar(
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
              (primaryEnabledListenable != null
                  ? ValueListenableBuilder<bool>(
                    valueListenable: primaryEnabledListenable!,
                    builder: (BuildContext _, bool isEnabled, Widget? __) {
                      return _buildActionButtons(context, colors, isEnabled);
                    },
                  )
                  : _buildActionButtons(context, colors, true)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    SemanticColors colors,
    bool isPrimaryEnabled,
  ) {
    return Padding(
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
          if (secondaryButtonText != null && primaryButtonText != null)
            const SizedBox(width: 12),
          if (primaryButtonText != null)
            Expanded(
              child: ButtonSolid(
                text: primaryButtonText!,
                textColor:
                    isPrimaryEnabled ? colors.staticWhite : colors.labelDisable,
                backgroundColor:
                    isPrimaryEnabled
                        ? colors.primaryNormal
                        : colors.interactionDisable,
                size: ButtonSize.large,
                onPressed:
                    isPrimaryEnabled
                        ? () {
                          Navigator.of(context).pop();
                          onPrimaryButtonPressed?.call();
                        }
                        : null,
              ),
            ),
        ],
      ),
    );
  }
}
