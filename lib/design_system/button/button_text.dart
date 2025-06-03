import 'package:flutter/material.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

enum ButtonTextSize { medium, small }

class ButtonText extends StatelessWidget {
  const ButtonText({
    super.key,
    required this.text,
    this.leftIcon,
    this.rightIcon,
    this.size = ButtonTextSize.medium,
    required this.textColor,
    this.onPressed,
  });

  final String text;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final ButtonTextSize size;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = _getTextStyle();
    final double iconSize = _getIconSize();
    const double gap = 4;
    const double interactionPadding = 7;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: interactionPadding,
            vertical: 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (leftIcon != null) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Icon(leftIcon, size: iconSize, color: textColor),
                ),
                const SizedBox(width: gap),
              ],
              Text(text, style: textStyle.copyWith(color: textColor)),
              if (rightIcon != null) ...<Widget>[
                const SizedBox(width: gap),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Icon(rightIcon, size: iconSize, color: textColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonTextSize.medium:
        return AppTextStyles.body1.normalBold;
      case ButtonTextSize.small:
        return AppTextStyles.label1.normalBold;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonTextSize.medium:
        return 20;
      case ButtonTextSize.small:
        return 16;
    }
  }
}
