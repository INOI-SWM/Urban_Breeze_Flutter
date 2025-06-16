import 'package:flutter/material.dart';
import 'package:ridingmate/core/design/typography/app_text_style.dart';

enum ChipActionSize { xsmall, small, medium, large }

enum ChipActionType { solid, outlined }

class ChipAction extends StatelessWidget {
  const ChipAction({
    super.key,
    required this.text,
    this.leftIcon,
    this.rightIcon,
    this.size = ChipActionSize.medium,
    this.type = ChipActionType.solid,
    required this.textColor,
    this.borderColor,
    this.backgroundColor,
    this.onPressed,
  }) : assert(
         type == ChipActionType.solid ? backgroundColor != null : true,
         'backgroundColor is required when type is solid',
       );

  final String text;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final ChipActionSize size;
  final ChipActionType type;
  final Color textColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final double borderRadius = _getBorderRadius();
    final EdgeInsets padding = _getPadding();
    final double iconSize = _getIconSize();
    final double gap = _getGap();
    final TextStyle textStyle = _getTextStyle();
    final EdgeInsets textPadding = _getTextPadding();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border:
            type == ChipActionType.outlined && borderColor != null
                ? Border.all(color: borderColor!)
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (leftIcon != null) ...<Widget>[
                  Icon(leftIcon, size: iconSize, color: textColor),
                  SizedBox(width: gap),
                ],
                Padding(
                  padding: textPadding,
                  child: Text(
                    text,
                    style: textStyle.copyWith(color: textColor),
                  ),
                ),
                if (rightIcon != null) ...<Widget>[
                  SizedBox(width: gap),
                  Icon(rightIcon, size: iconSize, color: textColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getBorderRadius() {
    switch (size) {
      case ChipActionSize.xsmall:
        return 6;
      case ChipActionSize.small:
        return 8;
      case ChipActionSize.medium:
      case ChipActionSize.large:
        return 10;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ChipActionSize.xsmall:
        return const EdgeInsets.symmetric(horizontal: 7, vertical: 4);
      case ChipActionSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 6);
      case ChipActionSize.medium:
        return const EdgeInsets.symmetric(horizontal: 11, vertical: 7);
      case ChipActionSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 9);
    }
  }

  EdgeInsets _getTextPadding() {
    switch (size) {
      case ChipActionSize.xsmall:
        return const EdgeInsets.symmetric(horizontal: 1);
      case ChipActionSize.small:
      case ChipActionSize.medium:
      case ChipActionSize.large:
        return const EdgeInsets.symmetric(horizontal: 2);
    }
  }

  double _getIconSize() {
    switch (size) {
      case ChipActionSize.xsmall:
        return 12;
      case ChipActionSize.small:
      case ChipActionSize.medium:
        return 14;
      case ChipActionSize.large:
        return 16;
    }
  }

  double _getGap() {
    switch (size) {
      case ChipActionSize.xsmall:
      case ChipActionSize.small:
        return 2;
      case ChipActionSize.medium:
      case ChipActionSize.large:
        return 3;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ChipActionSize.xsmall:
        return AppTextStyles.caption1.medium;
      case ChipActionSize.small:
        return AppTextStyles.label1.normalMedium;
      case ChipActionSize.medium:
      case ChipActionSize.large:
        return AppTextStyles.body2.normalMedium;
    }
  }
}
