import 'package:flutter/material.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';

enum ContentBadgeSize { xsmall, small, medium }

enum ContentBadgeType { solid, outlined }

class ContentBadge extends StatelessWidget {
  const ContentBadge({
    super.key,
    required this.text,
    this.leftIcon,
    this.rightIcon,
    this.size = ContentBadgeSize.medium,
    this.type = ContentBadgeType.solid,
    required this.backgroundColor,
    required this.textColor,
  });

  final String text;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final ContentBadgeSize size;
  final ContentBadgeType type;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final double height = _getHeight();
    final double borderRadius = _getBorderRadius();
    final EdgeInsets padding = _getPadding();
    final double iconSize = _getIconSize();
    final double gap = _getGap();
    final TextStyle textStyle = _getTextStyle();

    return Container(
      height: height,
      decoration: BoxDecoration(
        color:
            type == ContentBadgeType.solid
                ? backgroundColor
                : Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border:
            type == ContentBadgeType.outlined
                ? Border.all(color: backgroundColor)
                : null,
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (leftIcon != null) ...<Widget>[
              Icon(leftIcon, size: iconSize, color: textColor),
              SizedBox(width: gap),
            ],
            Text(text, style: textStyle.copyWith(color: textColor)),
            if (rightIcon != null) ...<Widget>[
              SizedBox(width: gap),
              Icon(rightIcon, size: iconSize, color: textColor),
            ],
          ],
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case ContentBadgeSize.xsmall:
        return 20;
      case ContentBadgeSize.small:
        return 24;
      case ContentBadgeSize.medium:
        return 28;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case ContentBadgeSize.xsmall:
      case ContentBadgeSize.small:
        return 6;
      case ContentBadgeSize.medium:
        return 8;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ContentBadgeSize.xsmall:
      case ContentBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6);
      case ContentBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 8);
    }
  }

  double _getIconSize() {
    switch (size) {
      case ContentBadgeSize.xsmall:
        return 12;
      case ContentBadgeSize.small:
        return 14;
      case ContentBadgeSize.medium:
        return 16;
    }
  }

  double _getGap() {
    switch (size) {
      case ContentBadgeSize.xsmall:
        return 2;
      case ContentBadgeSize.small:
        return 3;
      case ContentBadgeSize.medium:
        return 4;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ContentBadgeSize.xsmall:
        return AppTextStyles.caption2.medium;
      case ContentBadgeSize.small:
        return AppTextStyles.caption1.medium;
      case ContentBadgeSize.medium:
        return AppTextStyles.label2.medium;
    }
  }
}
