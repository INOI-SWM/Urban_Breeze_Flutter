import 'package:flutter/material.dart';
import 'package:ridingmate/core/design/typography/app_text_style.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';

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
