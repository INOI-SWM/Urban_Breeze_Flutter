import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/app_setting/application/use_cases/submit_feedback_use_case.dart';
import 'package:urban_breeze/features/app_setting/data/models/feedback_response_model.dart';
import 'package:urban_breeze/features/app_setting/di/app_setting_providers.dart';
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
import 'package:urban_breeze/shared/screens/webview_constant.dart';
import 'package:urban_breeze/shared/utils/webview_navigation.dart';

class SettingsScreen extends ConsumerWidget with ErrorDisplayMixin {
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
                SettingsItem(
                  title: '서비스 이용약관',
                  onPressed: () {
                    AmplitudeAnalytics.logButtonClick(
                      'settings_terms_of_service',
                    );
                    WebViewNavigation.navigateToWebView(
                      context,
                      url: servicePolicyUrl,
                      title: '서비스 이용약관',
                    );
                  },
                ),
                SettingsItem(
                  title: '개인정보 처리방침',
                  onPressed: () {
                    AmplitudeAnalytics.logButtonClick(
                      'settings_privacy_policy',
                    );
                    WebViewNavigation.navigateToWebView(
                      context,
                      url: privacyPolicyUrl,
                      title: '개인정보 처리방침',
                    );
                  },
                ),
                SettingsItem(
                  title: '위치기반 서비스 이용약관',
                  onPressed: () {
                    AmplitudeAnalytics.logButtonClick(
                      'settings_location_service',
                    );
                    WebViewNavigation.navigateToWebView(
                      context,
                      url: locationPolicyUrl,
                      title: '위치기반서비스 동의',
                    );
                  },
                ),
                SettingsItem(
                  title: '피드백 및 문의',
                  onPressed: () {
                    AmplitudeAnalytics.logButtonClick('settings_feedback');
                    _showFeedbackDialog(context, ref);
                  },
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
                    child: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<PackageInfo> snapshot,
                      ) {
                        return Text(
                          snapshot.hasData ? snapshot.data!.version : '...',
                          style: AppTextStyles.body2.normalRegular.copyWith(
                            color: colors.labelAssistive,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SettingsSection(
              children: <Widget>[
                // SettingsItem(
                //   title: '알림 설정',
                //   onPressed: () {
                //     AmplitudeAnalytics.logButtonClick('settings_notifications');
                //   },
                // ),
                SettingsItem(
                  title: '테마 모드',
                  rightWidget: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Consumer(
                      builder: (BuildContext context, WidgetRef ref, _) {
                        final ThemeMode currentThemeMode = ref.watch(
                          themeModeNotifierProvider,
                        );
                        return Text(
                          _getThemeModeDisplayName(currentThemeMode),
                          style: AppTextStyles.body2.normalRegular.copyWith(
                            color: colors.labelAlternative,
                          ),
                        );
                      },
                    ),
                  ),
                  onPressed: () {
                    AmplitudeAnalytics.logButtonClick('settings_theme_mode');
                    _showThemeModeDialog(context, ref);
                  },
                ),
                SettingsItem(
                  title: '계정 관리',
                  onPressed: () {
                    AmplitudeAnalytics.logButtonClick(
                      'settings_account_management',
                    );
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
                  onPressed: () {
                    AmplitudeAnalytics.logButtonClick('settings_logout');
                    _showLogoutDialog(context, ref);
                  },
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

  void _showFeedbackDialog(BuildContext context, WidgetRef ref) {
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
      onPrimaryButtonPressed:
          () => _submitFeedback(context, ref, controller.text),
      onSecondaryButtonPressed: () {},
    );
  }

  Future<void> _submitFeedback(
    BuildContext context,
    WidgetRef ref,
    String content,
  ) async {
    try {
      final SubmitFeedbackUseCase submitFeedbackUseCase = ref.read(
        submitFeedbackUseCaseProvider,
      );

      final AppResult<FeedbackResponseModel> result =
          await submitFeedbackUseCase.execute(content);

      if (result.isSuccess) {
        AmplitudeAnalytics.logEvent(
          'feedback_submitted',
          properties: <String, dynamic>{
            'feedback_length': content.length,
            'feedback_id': result.dataOrNull?.id,
          },
        );

        if (context.mounted) {
          showSuccessMessage(context, '피드백이 전송되었습니다.');
        }
      } else {
        if (context.mounted) {
          showErrorMessage(context, '피드백 전송에 실패했습니다. 다시 시도해주세요.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        showErrorMessage(context, '피드백 전송 중 오류가 발생했습니다.');
      }
    }
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

  String _getThemeModeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
      case ThemeMode.system:
        return '시스템 설정';
    }
  }

  void _showThemeModeDialog(BuildContext context, WidgetRef ref) {
    final SemanticColors colors = context.semanticColor;
    final ThemeMode currentThemeMode = ref.read(themeModeNotifierProvider);
    final ValueNotifier<ThemeMode> selectedThemeMode = ValueNotifier<ThemeMode>(
      currentThemeMode,
    );

    ModalShow.show(
      context: context,
      title: '테마 모드',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: selectedThemeMode,
          builder: (
            BuildContext context,
            ThemeMode selectedMode,
            Widget? child,
          ) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildThemeModeOption(
                  context,
                  ref,
                  colors,
                  ThemeMode.light,
                  '라이트 모드',
                  selectedMode == ThemeMode.light,
                  selectedThemeMode,
                ),
                const SizedBox(height: 12),
                _buildThemeModeOption(
                  context,
                  ref,
                  colors,
                  ThemeMode.dark,
                  '다크 모드',
                  selectedMode == ThemeMode.dark,
                  selectedThemeMode,
                ),
                const SizedBox(height: 12),
                _buildThemeModeOption(
                  context,
                  ref,
                  colors,
                  ThemeMode.system,
                  '시스템 설정',
                  selectedMode == ThemeMode.system,
                  selectedThemeMode,
                ),
              ],
            );
          },
        ),
      ),
      primaryButtonText: '확인',
      secondaryButtonText: '취소',
      onPrimaryButtonPressed: () {
        final ThemeMode newThemeMode = selectedThemeMode.value;
        if (newThemeMode != currentThemeMode) {
          ref
              .read(themeModeNotifierProvider.notifier)
              .setThemeMode(newThemeMode);
          AmplitudeAnalytics.logEvent(
            'theme_mode_changed',
            properties: <String, dynamic>{'theme_mode': newThemeMode.name},
          );
        }
      },
      onSecondaryButtonPressed: () {},
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context,
    WidgetRef ref,
    SemanticColors colors,
    ThemeMode themeMode,
    String title,
    bool isSelected,
    ValueNotifier<ThemeMode> selectedThemeMode,
  ) {
    return GestureDetector(
      onTap: () {
        selectedThemeMode.value = themeMode;
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colors.primaryNormal.withValues(alpha: 0.1)
                  : colors.backgroundElevatedAlternative,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primaryNormal : colors.lineNormalNeutral,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body1.normalMedium.copyWith(
                  color: isSelected ? colors.primaryNormal : colors.labelNormal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.primaryNormal, size: 24),
          ],
        ),
      ),
    );
  }
}
