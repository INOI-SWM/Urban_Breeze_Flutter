import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/auth/application/providers/user_session_notifier.dart';
import 'package:ridingmate/features/login/domain/entities/user.dart';
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
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(userSessionProvider.notifier).clearUserSession();
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }

  String _getInitials(User user) {
    if (user.displayName?.isNotEmpty == true) {
      return user.displayName![0].toUpperCase();
    }
    return user.email[0].toUpperCase();
  }
}
