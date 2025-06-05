import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

enum ChipFilterSize { xsmall, small, medium, large }

enum ChipFilterType { solid, outlined }

class ChipFilter extends StatelessWidget {
  const ChipFilter({
    super.key,
    required this.text,
    this.size = ChipFilterSize.medium,
    this.type = ChipFilterType.solid,
    required this.textColor,
    this.iconColor,
    this.borderColor,
    this.backgroundColor,
    this.onPressed,
  }) : assert(
         type == ChipFilterType.solid ? backgroundColor != null : true,
         'backgroundColor is required when type is solid',
       );

  final String text;
  final ChipFilterSize size;
  final ChipFilterType type;
  final Color textColor;
  final Color? iconColor;
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
            type == ChipFilterType.outlined && borderColor != null
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
                Padding(
                  padding: textPadding,
                  child: Text(
                    text,
                    style: textStyle.copyWith(color: textColor),
                  ),
                ),
                SizedBox(width: gap),
                SvgPicture.asset(
                  'assets/icons/svg/caret_down.svg',
                  width: iconSize,
                  height: iconSize,
                  colorFilter: ColorFilter.mode(
                    iconColor ?? textColor,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getBorderRadius() {
    switch (size) {
      case ChipFilterSize.xsmall:
        return 6;
      case ChipFilterSize.small:
        return 8;
      case ChipFilterSize.medium:
      case ChipFilterSize.large:
        return 10;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ChipFilterSize.xsmall:
        return const EdgeInsets.fromLTRB(7, 4, 5, 4);
      case ChipFilterSize.small:
        return const EdgeInsets.fromLTRB(8, 6, 6, 6);
      case ChipFilterSize.medium:
        return const EdgeInsets.fromLTRB(11, 7, 9, 7);
      case ChipFilterSize.large:
        return const EdgeInsets.fromLTRB(12, 9, 10, 9);
    }
  }

  EdgeInsets _getTextPadding() {
    switch (size) {
      case ChipFilterSize.xsmall:
        return const EdgeInsets.symmetric(horizontal: 1);
      case ChipFilterSize.small:
      case ChipFilterSize.medium:
      case ChipFilterSize.large:
        return const EdgeInsets.symmetric(horizontal: 2);
    }
  }

  double _getIconSize() {
    switch (size) {
      case ChipFilterSize.xsmall:
        return 12;
      case ChipFilterSize.small:
      case ChipFilterSize.medium:
        return 14;
      case ChipFilterSize.large:
        return 16;
    }
  }

  double _getGap() {
    switch (size) {
      case ChipFilterSize.xsmall:
      case ChipFilterSize.small:
        return 1;
      case ChipFilterSize.medium:
      case ChipFilterSize.large:
        return 2;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ChipFilterSize.xsmall:
        return AppTextStyles.caption1.medium;
      case ChipFilterSize.small:
        return AppTextStyles.label1.normalMedium;
      case ChipFilterSize.medium:
      case ChipFilterSize.large:
        return AppTextStyles.body2.normalMedium;
    }
  }
}
