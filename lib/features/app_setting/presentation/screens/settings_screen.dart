import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/auth/application/use_cases/auth_sign_out_facade.dart';
import 'package:ridingmate/features/auth/di/auth_providers.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:ridingmate/shared/design_system/widgets/modal/modal_show.dart';
import 'package:ridingmate/shared/mixins/error_display_mixin.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  padding: const EdgeInsets.only(right: 6),
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
                onPressed: () => _showLogoutDialog(context, ref),
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
      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
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
        result.add(Divider(color: colors.lineNormalNormal, height: 24));
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
          if (trailing != null)
            Padding(padding: const EdgeInsets.only(right: 6), child: trailing),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    ModalShow.show(
      context: context,
      title: '로그아웃',
      content: const Text('정말 로그아웃하시겠습니까?'),
      primaryButtonText: '로그아웃',
      secondaryButtonText: '취소',
      onPrimaryButtonPressed: () => _handleSignOut(context, ref),
      onSecondaryButtonPressed: () => Navigator.of(context).pop(),
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    try {
      final User? user = ref.read(userSessionNotifierProvider);
      if (user == null) return;

      final AuthSignOutFacade authSignOutFacade = ref.read(
        authSignOutFacadeProvider,
      );
      await authSignOutFacade.execute(user.loginProvider);

      if (!context.mounted) return;

      ErrorDisplay.showSuccessMessage(context, '로그아웃되었습니다.');

      // 모든 화면을 제거하고 홈으로 이동 (임시 코드)
      Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
    } catch (e) {
      if (!context.mounted) return;

      ErrorDisplay.showErrorMessage(context, '로그아웃 실패: ${e.toString()}');
      Navigator.of(context).pop();
    }
  }
}
