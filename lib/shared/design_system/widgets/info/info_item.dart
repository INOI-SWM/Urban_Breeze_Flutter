import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';

class InfoItem extends StatelessWidget {
  const InfoItem({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: AppTextStyles.label1.readingBold.copyWith(
            color: colors.labelAlternative,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body1.readingBold.copyWith(
            color: colors.labelNormal,
          ),
        ),
      ],
    );
  }
}
