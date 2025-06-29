import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';

class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '프로필 수정',
        leading: GestureDetector(
          child: const SizedBox(
            width: 24,
            height: 24,
            child: Icon(Icons.arrow_back_ios_new, size: 24),
          ),
        ),
      ),

      body: const Center(child: Text('프로필 수정 화면')),
    );
  }
}
