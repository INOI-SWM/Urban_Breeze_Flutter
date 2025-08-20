import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/app_setting/presentation/screens/account_management_screen.dart';
import 'package:urban_breeze/features/app_setting/presentation/widgets/settings_list.dart';
import 'package:urban_breeze/features/auth/application/use_cases/auth_sign_out_facade.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/main.dart';
import 'package:urban_breeze/shared/design_system/tokens/decorations/inset_border.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/design_system/widgets/modal/modal_show.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

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
            SettingsSection(
              children: <Widget>[
                SettingsItem(title: '이용 약관', onPressed: () {}),
                SettingsItem(title: '개인정보 처리방침', onPressed: () {}),
                SettingsItem(
                  title: '피드백 및 문의',
                  onPressed: () => _showFeedbackDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SettingsSection(
              children: <Widget>[
                SettingsItem(
                  title: '버전 정보',
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
              ],
            ),

            const SizedBox(height: 20),

            SettingsSection(
              children: <Widget>[
                SettingsItem(title: '알림 설정', onPressed: () {}),
                SettingsItem(
                  title: '계정 관리',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder:
                            (BuildContext context) =>
                                const AccountManagementScreen(),
                      ),
                    );
                  },
                ),
                SettingsItem(
                  title: '로그아웃',
                  onPressed: () => _showLogoutDialog(context, ref),
                  showArrow: false,
                  textColor: colors.statusNegative,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final TextEditingController controller = TextEditingController();
    final ValueNotifier<bool> isSendEnabled = ValueNotifier<bool>(
      controller.text.trim().isNotEmpty,
    );

    controller.addListener(() {
      isSendEnabled.value = controller.text.trim().isNotEmpty;
    });

    ModalShow.show(
      context: context,
      title: '피드백 및 문의',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '서비스 개선을 위해 의견을 보내주세요.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body2.normalRegular.copyWith(
                color: colors.labelNeutral,
              ),
            ),
            const SizedBox(height: 12),
            InsetBorder(
              color: colors.lineNormalNeutral,
              width: 1,
              radius: 12,
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 120,
                  maxHeight: 220,
                ),
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  minLines: 5,
                  cursorColor: colors.primaryNormal,
                  style: AppTextStyles.body1.normalRegular.copyWith(
                    color: colors.labelNormal,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: '내용을 입력해 주세요.',
                    hintStyle: AppTextStyles.body1.normalRegular.copyWith(
                      color: colors.labelAssistive,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      primaryButtonText: '보내기',
      secondaryButtonText: '취소',
      primaryEnabledListenable: isSendEnabled,
      onPrimaryButtonPressed: () {
        ErrorDisplay.showSuccessMessage(context, '피드백이 전송되었습니다. 감사합니다!');
      },
      onSecondaryButtonPressed: () {},
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    ModalShow.show(
      context: context,
      title: '로그아웃',
      content: Text(
        '정말 로그아웃하시겠습니까?',
        style: AppTextStyles.body1.normalRegular.copyWith(
          color: context.semanticColor.labelNormal,
        ),
      ),
      primaryButtonText: '로그아웃',
      secondaryButtonText: '취소',
      onPrimaryButtonPressed: () => _handleSignOut(context, ref),
      onSecondaryButtonPressed: () {},
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

      // 앱 재시작
      restartableAppKey.currentState?.restart();
    } catch (e) {
      if (!context.mounted) return;

      ErrorDisplay.showErrorMessage(context, '로그아웃 실패: ${e.toString()}');
      Navigator.of(context).pop();
    }
  }
}
