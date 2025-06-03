import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/design_system/Icon/icon_size.dart';

enum IconButtonSize {
  medium(40),
  small(32),
  custom(0);

  const IconButtonSize(this.size);
  final double size;
}

class IconButtonSolid extends StatelessWidget {
  const IconButtonSolid({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.buttonSize,
    required this.iconSize,
    this.customButtonSize,
    this.backgroundColor,
    this.iconColor,
    this.shadow,
  }) : assert(
         buttonSize != IconButtonSize.custom || customButtonSize != null,
         'customButtonSize must be provided when buttonSize is custom',
       );

  final IconData icon;
  final VoidCallback onPressed;
  final IconButtonSize buttonSize;
  final IconSize iconSize;
  final double? customButtonSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final double size =
        buttonSize == IconButtonSize.custom
            ? customButtonSize!
            : buttonSize.size;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? context.semanticColor.primaryNormal,
        boxShadow: shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              size: iconSize.size,
              color: iconColor ?? context.semanticColor.staticWhite,
            ),
          ),
        ),
      ),
    );
  }
}
