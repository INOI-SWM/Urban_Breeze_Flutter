import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';

class ProfileEditLayout extends StatelessWidget {
  const ProfileEditLayout({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppTextStyles.headline1.bold.copyWith(
              color: colors.labelStrong,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: AppTextStyles.body2.normalRegular.copyWith(
              color: colors.labelNormal,
            ),
          ),

          const SizedBox(height: 24),

          child,
        ],
      ),
    );
  }
}
