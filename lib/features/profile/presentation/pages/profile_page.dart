import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/auth/di/auth_providers.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/profile/presentation/screens/login_required_screen.dart';
import 'package:ridingmate/features/profile/presentation/screens/profile_screen.dart';
import 'package:ridingmate/features/profile/presentation/screens/settings_screen.dart';
import 'package:ridingmate/navigation/page_with_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';

class ProfilePage extends ConsumerWidget implements PageWithAppBar {
  const ProfilePage({super.key});
  @override
  PreferredSizeWidget getAppBar(BuildContext context) {
    return CustomAppBar(
      title: 'MY',
      actions: <Widget>[
        IconButton(
          onPressed: () => _navigateToSettings(context),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = ref.watch(userSessionNotifierProvider);
    final bool isLoggedIn = ref.watch(isLoggedInProvider);

    if (isLoggedIn && user != null) {
      return ProfileScreen(user: user);
    } else {
      return const LoginRequiredScreen();
    }
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const SettingsScreen(),
      ),
    );
  }
}
