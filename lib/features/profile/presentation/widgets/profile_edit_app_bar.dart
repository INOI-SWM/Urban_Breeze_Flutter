import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';

class ProfileEditAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileEditAppBar({
    super.key,
    required this.title,
    required this.isButtonEnabled,
    required this.onSave,
  });

  final String title;
  final bool isButtonEnabled;
  final VoidCallback onSave;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return CustomAppBar(
      title: title,
      leading: CustomIconButton(
        icon: Icons.arrow_back_ios_new,
        onTap: () => Navigator.of(context).pop(),
      ),
      actions: <Widget>[
        GestureDetector(
          onTap: isButtonEnabled ? onSave : null,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '완료',
                  style: AppTextStyles.label1.normalBold.copyWith(
                    color:
                        isButtonEnabled
                            ? colors.primaryNormal
                            : colors.labelDisable,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
