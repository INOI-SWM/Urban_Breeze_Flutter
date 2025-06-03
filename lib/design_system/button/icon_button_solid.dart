import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/design_system/Icon/icon_size.dart';

enum IconButtonSize {
  small(32),
  medium(40);

  const IconButtonSize(this.size);
  final double size;
}

class IconButtonSolid extends StatelessWidget {
  const IconButtonSolid({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.iconSize,
    this.buttonSize,
    this.customButtonSize,
    this.backgroundColor,
    this.iconColor,
    this.shadow,
  }) : assert(
         buttonSize != null || customButtonSize != null,
         'Either buttonSize or customButtonSize must be provided',
       );

  final IconData icon;
  final VoidCallback onPressed;
  final IconSize iconSize;
  final IconButtonSize? buttonSize;
  final double? customButtonSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final List<BoxShadow>? shadow;

  double get _buttonSize => customButtonSize ?? buttonSize!.size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _buttonSize,
      height: _buttonSize,
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
