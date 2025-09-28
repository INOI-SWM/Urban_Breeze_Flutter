import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/app_setting/application/services/account_management_controller.dart';
import 'package:urban_breeze/features/app_setting/presentation/widgets/settings_list.dart';
import 'package:urban_breeze/main.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/design_system/widgets/modal/modal_show.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class AccountManagementScreen extends ConsumerWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SemanticColors colors = context.semanticColor;

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: CustomAppBar(
        title: '계정 관리',
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
                  title: '탈퇴하기',
                  onPressed: () {
                    AmplitudeAnalytics.logButtonClick('account_withdrawal');
                    _showWithdrawalDialog(context, ref);
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

  void _showWithdrawalDialog(BuildContext context, WidgetRef ref) {
    final SemanticColors colors = context.semanticColor;
    ModalShow.show(
      context: context,
      title: '탈퇴하기',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '정말 탈퇴하시겠습니까?',
            style: AppTextStyles.body1.normalBold.copyWith(
              color: colors.accentForegroundRed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• 계정과 모든 데이터가 삭제됩니다\n• 삭제된 데이터는 복구할 수 없습니다',
            style: AppTextStyles.body2.normalBold.copyWith(
              color: colors.labelNormal,
            ),
          ),
        ],
      ),
      primaryButtonText: '탈퇴하기',
      secondaryButtonText: '취소',
      onPrimaryButtonPressed: () => _handleWithdrawal(context, ref),
    );
  }

  Future<void> _handleWithdrawal(BuildContext context, WidgetRef ref) async {
    try {
      final AccountManagementController controller = ref.read(
        accountManagementControllerProvider,
      );
      await controller.withdraw();

      if (!context.mounted) return;

      // 탈퇴 성공 이벤트
      AmplitudeAnalytics.logEvent('account_withdrawal_success');

      // 앱 재시작
      restartableAppKey.currentState?.restart();
    } catch (e) {
      if (!context.mounted) return;

      // 탈퇴 실패 이벤트
      AmplitudeAnalytics.logEvent(
        'account_withdrawal_failed',
        properties: <String, dynamic>{'error_message': e.toString()},
      );

      ErrorDisplay.showErrorMessage(
        context,
        '탈퇴 실패: 문제가 반복될 경우 문의창을 통하여 문의해주세요',
      );
      Navigator.of(context).pop();
    }
  }
}
