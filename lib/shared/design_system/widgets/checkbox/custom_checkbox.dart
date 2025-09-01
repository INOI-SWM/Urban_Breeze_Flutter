import 'package:flutter/material.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 20.0,
    this.colors,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;
  final SemanticColors? colors;

  @override
  Widget build(BuildContext context) {
    final SemanticColors semanticColors =
        colors ?? Theme.of(context).extension<SemanticColors>()!;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(
            color:
                value
                    ? semanticColors.primaryNormal
                    : semanticColors.labelNormal,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
          color: value ? semanticColors.primaryNormal : Colors.transparent,
        ),
        child:
            value
                ? Icon(
                  Icons.check,
                  size: size * 0.7,
                  color: semanticColors.staticWhite,
                )
                : null,
      ),
    );
  }
}
