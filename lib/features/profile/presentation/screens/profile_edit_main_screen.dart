import 'package:flutter/material.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/presentation/screens/profile_bio_edit_screen.dart';
import 'package:urban_breeze/features/profile/presentation/screens/profile_birth_year_edit_screen.dart';
import 'package:urban_breeze/features/profile/presentation/screens/profile_gender_edit_screen.dart';
import 'package:urban_breeze/features/profile/presentation/screens/profile_nickname_edit_screen.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_item.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_image_edit_button.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/utils/platform_action_sheet.dart';

class ProfileEditMainScreen extends StatefulWidget {
  const ProfileEditMainScreen({super.key, required this.user});

  final User user;

  @override
  State<ProfileEditMainScreen> createState() => _ProfileEditMainScreenState();
}

class _ProfileEditMainScreenState extends State<ProfileEditMainScreen> {
  String _nickname = '';
  String _bio = '';
  String _gender = '';
  String _birthYear = '';

  @override
  void initState() {
    super.initState();
    // TODO : 프로필 정보 가져오기 api 호출 후 데이터 설정
    _nickname = widget.user.displayName ?? '';
    _bio = '자신을 소개해주세요';
    _gender = '선택해주세요';
    _birthYear = '선택해주세요';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView('profile_edit_screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: CustomAppBar(
        title: '프로필 수정',
        leading: CustomIconButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ProfileImageEditButton(
                //TODO : 기본 이미지 설정
                imageUrl: widget.user.photoUrl!,
                onPressed: () {
                  AmplitudeAnalytics.logButtonClick('profile_image_edit');
                  _showProfileImageOptions();
                },
              ),

              ProfileEditItem(
                title: '닉네임',
                currentValue: _nickname.isEmpty ? '설정되지 않음' : _nickname,
                onPressed: () => _navigateToNicknameEdit(),
              ),

              const SizedBox(height: 36),

              ProfileEditItem(
                title: '한 줄 소개',
                currentValue: _bio,
                onPressed: () => _navigateToBioEdit(),
              ),

              const SizedBox(height: 36),

              ProfileEditItem(
                title: '성별',
                currentValue: _gender,
                onPressed: () => _navigateToGenderEdit(),
              ),

              const SizedBox(height: 36),

              ProfileEditItem(
                title: '출생년도',
                currentValue: _birthYear,
                onPressed: () => _navigateToBirthYearEdit(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNicknameEdit() async {
    AmplitudeAnalytics.logButtonClick('profile_nickname_edit');
    final String? result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder:
            (BuildContext context) =>
                ProfileNicknameEditScreen(currentValue: _nickname),
      ),
    );

    if (result != null) {
      setState(() {
        _nickname = result;
      });
    }
  }

  void _navigateToBioEdit() async {
    AmplitudeAnalytics.logButtonClick('profile_bio_edit');
    final String? result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder:
            (BuildContext context) => ProfileBioEditScreen(currentValue: _bio),
      ),
    );

    if (result != null) {
      setState(() {
        _bio = result;
      });
    }
  }

  void _navigateToGenderEdit() async {
    AmplitudeAnalytics.logButtonClick('profile_gender_edit');
    final String? result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder:
            (BuildContext context) =>
                ProfileGenderEditScreen(currentValue: _gender),
      ),
    );

    if (result != null) {
      setState(() {
        _gender = result;
      });
    }
  }

  void _navigateToBirthYearEdit() async {
    AmplitudeAnalytics.logButtonClick('profile_birth_year_edit');
    final String? result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder:
            (BuildContext context) =>
                ProfileBirthYearEditScreen(currentValue: _birthYear),
      ),
    );

    if (result != null) {
      setState(() {
        _birthYear = result;
      });
    }
  }

  void _showProfileImageOptions() {
    showPlatformActionSheet(
      context,
      title: '프로필 사진 수정',
      options: <PlatformActionSheetOption>[
        PlatformActionSheetOption(
          title: '사진 촬영',
          onSelected: () {
            AmplitudeAnalytics.logButtonClick('profile_image_camera');
            // TODO: 카메라로 사진 촬영 기능 구현
          },
        ),
        PlatformActionSheetOption(
          title: '앨범에서 사진 선택',
          onSelected: () {
            AmplitudeAnalytics.logButtonClick('profile_image_gallery');
            // TODO: 갤러리에서 사진 선택 기능 구현
          },
        ),
        PlatformActionSheetOption(
          title: '사진 삭제',
          onSelected: () {
            AmplitudeAnalytics.logButtonClick('profile_image_delete');
            // TODO: 프로필 사진 삭제 기능 구현
          },
          isDestructive: true,
        ),
      ],
    );
  }
}
