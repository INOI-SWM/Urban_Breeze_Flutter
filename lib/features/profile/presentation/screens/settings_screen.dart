import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: CustomAppBar(
        title: '설정',
        leading: CustomIconButton(
          onTap: () => Navigator.pop(context),
          icon: Icons.arrow_back_ios_new_outlined,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            _buildSettingsSection(context, <Widget>[
              _buildSettingsItem(context, '이용 약관', onPressed: () {}),
              _buildSettingsItem(context, '개인정보 처리방침', onPressed: () {}),
              _buildSettingsItem(context, '고객 센터', onPressed: () {}),
            ]),

            const SizedBox(height: 20),

            _buildSettingsSection(context, <Widget>[
              _buildSettingsItem(
                context,
                '버전 정보',
                rightWidget: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '1.0.0',
                    style: AppTextStyles.body2.normalRegular.copyWith(
                      color: colors.labelAssistive,
                    ),
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 20),

            _buildSettingsSection(context, <Widget>[
              _buildSettingsItem(context, '알림 설정', onPressed: () {}),
              _buildSettingsItem(context, '계정 관리', onPressed: () {}),
              _buildSettingsItem(
                context,
                '로그아웃',
                onPressed: () {},
                showArrow: false,
                textColor: colors.statusNegative,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, List<Widget> items) {
    final SemanticColors colors = context.semanticColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
      decoration: BoxDecoration(
        color: colors.backgroundElevatedAlternative,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(children: _addDividers(items, colors)),
    );
  }

  List<Widget> _addDividers(List<Widget> items, SemanticColors colors) {
    final List<Widget> result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(Divider(color: colors.lineNormalNormal, height: 16));
      }
    }
    return result;
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title, {
    VoidCallback? onPressed,
    Widget? rightWidget,
    bool showArrow = true,
    Color? textColor,
  }) {
    final SemanticColors colors = context.semanticColor;

    Widget? trailing;
    if (rightWidget != null) {
      trailing = rightWidget;
    } else if (showArrow) {
      trailing = Icon(
        Icons.arrow_forward_ios,
        size: 24,
        color: colors.labelAssistive,
      );
    }

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: AppTextStyles.body1.normalMedium.copyWith(
              color: textColor ?? colors.labelNormal,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
