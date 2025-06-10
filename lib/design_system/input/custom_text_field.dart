import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({super.key, required this.title, this.description});

  final String title;
  final String? description;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              widget.title,
              style: AppTextStyles.label1.normalBold.copyWith(
                color: colors.labelNeutral,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTextStyles.label1.normalMedium.copyWith(
                color: colors.statusNegative,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.lineNormalNeutral),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '텍스트를 입력해 주세요.',
                  style: AppTextStyles.body1.normalRegular.copyWith(
                    color: colors.labelAssistive,
                  ),
                ),
              ),
              const Icon(Icons.star),
            ],
          ),
        ),
        if (widget.description != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            widget.description!,
            style: AppTextStyles.caption1.regular.copyWith(
              color: colors.labelAlternative,
            ),
          ),
        ],
      ],
    );
  }
}
