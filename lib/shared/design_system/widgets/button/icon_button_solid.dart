import 'package:flutter/material.dart';
import 'package:ridingmate/shared/design_system/widgets/icon/icon_size.dart';

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
    required this.backgroundColor,
    required this.iconColor,
    this.buttonSize,
    this.customButtonSize,
    this.shadow,
    this.isDisabled = false,
  }) : assert(
         buttonSize != null || customButtonSize != null,
         'Either buttonSize or customButtonSize must be provided',
       );

  final IconData icon;
  final VoidCallback onPressed;
  final IconSize iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final IconButtonSize? buttonSize;
  final double? customButtonSize;
  final List<BoxShadow>? shadow;
  final bool isDisabled;

  double get _buttonSize => customButtonSize ?? buttonSize!.size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _buttonSize,
      height: _buttonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        boxShadow: shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          customBorder: const CircleBorder(),
          splashColor: isDisabled ? Colors.transparent : null,
          highlightColor: isDisabled ? Colors.transparent : null,
          child: Center(
            child: Icon(icon, size: iconSize.size, color: iconColor),
          ),
        ),
      ),
    );
  }
}
