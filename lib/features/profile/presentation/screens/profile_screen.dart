import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/auth/application/use_cases/auth_sign_out_facade.dart';
import 'package:ridingmate/features/auth/application/use_cases/auth_withdrawal_facade.dart';
import 'package:ridingmate/features/auth/di/auth_providers.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_outlined.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_size.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_solid.dart';
import 'package:ridingmate/shared/design_system/widgets/info/info_item.dart';
import 'package:ridingmate/shared/mixins/error_display_mixin.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SemanticColors colors = context.semanticColor;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 40,
                backgroundImage:
                    user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child:
                    //TODO: 프로필 기본이미지 추가
                    user.photoUrl == null
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
              ),
              const Expanded(
                child: InfoItem(label: '총 주행시간', value: '100시간 30분'),
              ),
              const Expanded(child: InfoItem(label: '총 주행거리', value: '1000km')),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            user.displayName ?? '이름 없음',
            style: AppTextStyles.body1.readingBold,
          ),
          Text('한줄소개입니다', style: AppTextStyles.body1.normalRegular),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ButtonOutlined(
              textColor: colors.labelNormal,
              borderColor: colors.lineNormalNeutral,
              onPressed: () => _onProfileEditPressed(context),
              text: '프로필 수정',
              size: ButtonSize.medium,
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ButtonSolid(
              text: '로그아웃',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              onPressed: () => _showLogoutDialog(context, ref),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ButtonSolid(
              text: '탈퇴하기',
              backgroundColor: Colors.grey[300]!,
              textColor: Colors.black87,
              onPressed: () => _showWithdrawalDialog(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('로그아웃'),
              content: const Text('정말 로그아웃하시겠습니까?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => _handleSignOut(context, ref),
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWithdrawalDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('탈퇴하기'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('정말 탈퇴하시겠습니까?'),
                  SizedBox(height: 8),
                  Text(
                    '• 계정과 모든 데이터가 삭제됩니다\n• 삭제된 데이터는 복구할 수 없습니다',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => _handleWithdrawal(context, ref),
                  child: const Text(
                    '탈퇴하기',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    try {
      final AuthSignOutFacade authSignOutFacade = ref.read(
        authSignOutFacadeProvider,
      );
      await authSignOutFacade.execute(user.loginProvider);

      if (!context.mounted) return;

      ErrorDisplay.showSuccessMessage(context, '로그아웃되었습니다.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;

      ErrorDisplay.showErrorMessage(context, '로그아웃 실패: ${e.toString()}');
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleWithdrawal(BuildContext context, WidgetRef ref) async {
    try {
      final AuthWithdrawalFacade authWithdrawalFacade = ref.read(
        authWithdrawalFacadeProvider,
      );
      await authWithdrawalFacade.execute(user.loginProvider);

      if (!context.mounted) return;

      ErrorDisplay.showSuccessMessage(context, '탈퇴가 완료되었습니다.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;

      ErrorDisplay.showErrorMessage(context, '탈퇴 실패: ${e.toString()}');
      Navigator.of(context).pop();
    }
  }

  void _onProfileEditPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ProfileEditScreen(user: user),
      ),
    );
  }
}
