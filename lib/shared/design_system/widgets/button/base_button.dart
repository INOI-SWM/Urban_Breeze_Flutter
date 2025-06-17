import 'package:flutter/material.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_size.dart';
import 'package:ridingmate/shared/design_system/widgets/icon/icon_size.dart';

abstract class BaseButton extends StatelessWidget {
  const BaseButton({
    super.key,
    this.text,
    this.leftIcon,
    this.rightIcon,
    this.size = ButtonSize.medium,
    required this.textColor,
    this.onPressed,
    this.shadow,
  }) : assert(
         text != null || leftIcon != null || rightIcon != null,
         '텍스트나 아이콘 중 하나는 반드시 있어야 합니다.',
       );

  final String? text;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final ButtonSize size;
  final Color textColor;
  final VoidCallback? onPressed;
  final List<BoxShadow>? shadow;

  BoxDecoration getDecoration(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final bool isIconOnly =
        text == null && (leftIcon != null || rightIcon != null);
    final EdgeInsets padding = getPadding(isIconOnly);
    final TextStyle textStyle = getTextStyle();
    final double iconSize = getIconSize();
    final double gap = getGap();
    final double borderRadius = getBorderRadius();

    return Container(
      decoration: getDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (leftIcon != null) ...<Widget>[
                  Icon(leftIcon, size: iconSize, color: textColor),
                  if (text != null) SizedBox(width: gap),
                ],
                if (text != null)
                  Text(text!, style: textStyle.copyWith(color: textColor)),
                if (rightIcon != null) ...<Widget>[
                  if (text != null) SizedBox(width: gap),
                  Icon(rightIcon, size: iconSize, color: textColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsets getPadding(bool isIconOnly) {
    switch (size) {
      case ButtonSize.large:
        return isIconOnly
            ? const EdgeInsets.all(12)
            : const EdgeInsets.symmetric(horizontal: 28, vertical: 12);
      case ButtonSize.medium:
        return isIconOnly
            ? const EdgeInsets.all(10)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 9);
      case ButtonSize.small:
        return isIconOnly
            ? const EdgeInsets.all(8)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 7);
    }
  }

  double getGap() {
    switch (size) {
      case ButtonSize.large:
        return 6;
      case ButtonSize.medium:
        return 5;
      case ButtonSize.small:
        return 4;
    }
  }

  TextStyle getTextStyle() {
    switch (size) {
      case ButtonSize.large:
        return AppTextStyles.body1.normalBold;
      case ButtonSize.medium:
        return AppTextStyles.body2.normalBold;
      case ButtonSize.small:
        return AppTextStyles.label2.bold;
    }
  }

  double getIconSize() {
    switch (size) {
      case ButtonSize.large:
        return IconSize.xlarge.size;
      case ButtonSize.medium:
        return IconSize.small.size;
      case ButtonSize.small:
        return 18;
    }
  }

  double getBorderRadius() {
    switch (size) {
      case ButtonSize.large:
        return 12;
      case ButtonSize.medium:
        return 10;
      case ButtonSize.small:
        return 8;
    }
  }
}
