import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/auth/di/auth_providers.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/profile/presentation/screens/login_required_screen.dart';
import 'package:ridingmate/features/profile/presentation/screens/profile_screen.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

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
}
