import 'package:flutter/material.dart';
import 'package:ridingmate/shared/design_system/widgets/button/base_button.dart';

class ButtonOutlined extends BaseButton {
  const ButtonOutlined({
    super.key,
    super.text,
    super.leftIcon,
    super.rightIcon,
    super.size,
    required super.textColor,
    required this.borderColor,
    super.onPressed,
    super.shadow,
  });

  final Color borderColor;

  @override
  BoxDecoration getDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(getBorderRadius()),
      border: Border.all(color: borderColor),
      boxShadow: shadow,
    );
  }
}
