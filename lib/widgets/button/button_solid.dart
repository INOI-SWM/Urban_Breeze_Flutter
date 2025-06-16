import 'package:flutter/material.dart';
import 'package:ridingmate/widgets/button/base_button.dart';

class ButtonSolid extends BaseButton {
  const ButtonSolid({
    super.key,
    super.text,
    super.leftIcon,
    super.rightIcon,
    super.size,
    required super.textColor,
    required this.backgroundColor,
    super.onPressed,
    super.shadow,
  });

  final Color backgroundColor;

  @override
  BoxDecoration getDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(getBorderRadius()),
      color: backgroundColor,
      boxShadow: shadow,
    );
  }
}
