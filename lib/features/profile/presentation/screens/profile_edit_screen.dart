import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';

class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 수정')),
      body: const Center(child: Text('프로필 수정 화면')),
    );
  }
}
