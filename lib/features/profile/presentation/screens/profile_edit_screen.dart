import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/profile/presentation/widgets/profile_edit_item.dart';
import 'package:ridingmate/features/profile/presentation/widgets/profile_image_edit_button.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: CustomAppBar(
        title: '프로필 수정',
        leading: GestureDetector(
          child: const SizedBox(
            width: 24,
            height: 24,
            child: Icon(Icons.arrow_back_ios_new, size: 24),
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ProfileImageEditButton(
                imageUrl: user.photoUrl!,
                onPressed: () {
                  // TODO: 프로필 사진 저장소, 또는 카메라로 수정 기능 추가
                },
              ),

              ProfileEditItem(
                title: '닉네임',
                currentValue: user.displayName ?? '설정되지 않음',
                onPressed: () => <dynamic, dynamic>{},
              ),

              const SizedBox(height: 36),

              ProfileEditItem(
                title: '한 줄 소개',
                currentValue: '자신을 소개해주세요',
                onPressed: () => <dynamic, dynamic>{},
              ),

              const SizedBox(height: 36),

              ProfileEditItem(
                title: '성별',
                currentValue: '한줄소개, 두줄소개, 세줄소개',
                onPressed: () => <dynamic, dynamic>{},
              ),

              const SizedBox(height: 36),

              ProfileEditItem(
                title: '출생년도',
                currentValue: '1999',
                onPressed: () => <dynamic, dynamic>{},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
