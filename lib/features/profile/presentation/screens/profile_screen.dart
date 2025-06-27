import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/auth/application/use_cases/auth_sign_out_facade.dart';
import 'package:ridingmate/features/auth/di/auth_providers.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_solid.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                    child:
                        user.photoUrl == null
                            ? Text(
                              _getInitials(user),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.displayName ?? '이름 없음',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          Text(
            '설정',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: '앱 설정',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: '도움말',
            onTap: () {},
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: '앱 정보',
            onTap: () {},
          ),

          const Spacer(),

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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
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
                  onPressed: () => _handleLogout(context, ref),
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

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      // 로그아웃 처리 (다이얼로그는 아직 열어둠)
      final AuthSignOutFacade authSignOutFacade = ref.read(
        authSignOutFacadeProvider,
      );
      await authSignOutFacade.execute(user.loginProvider);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그아웃되었습니다.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그아웃 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  Future<void> _handleWithdrawal(BuildContext context, WidgetRef ref) async {
    try {
      // TODO: 탈퇴 처리 구현 (다이얼로그는 아직 열어둠)

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('탈퇴가 완료되었습니다.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('탈퇴 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  String _getInitials(User user) {
    if (user.displayName?.isNotEmpty == true) {
      return user.displayName![0].toUpperCase();
    }
    return user.email[0].toUpperCase();
  }
}
