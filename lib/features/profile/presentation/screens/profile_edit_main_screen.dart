import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/application/use_cases/upload_profile_image_use_case.dart';
import 'package:urban_breeze/features/profile/di/profile_providers.dart';
import 'package:urban_breeze/features/profile/presentation/screens/profile_bio_edit_screen.dart';
import 'package:urban_breeze/features/profile/presentation/screens/profile_birth_year_edit_screen.dart';
import 'package:urban_breeze/features/profile/presentation/screens/profile_gender_edit_screen.dart';
import 'package:urban_breeze/features/profile/presentation/screens/profile_nickname_edit_screen.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_item.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_image_edit_button.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';
import 'package:urban_breeze/shared/utils/platform_action_sheet.dart';

class ProfileEditMainScreen extends ConsumerStatefulWidget {
  const ProfileEditMainScreen({super.key});

  @override
  ConsumerState<ProfileEditMainScreen> createState() =>
      _ProfileEditMainScreenState();
}

class _ProfileEditMainScreenState extends ConsumerState<ProfileEditMainScreen>
    with ErrorDisplayMixin {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 이미 데이터가 없을 때만 로드 (깜빡임 방지)
      final User? currentUser = ref.read(userSessionNotifierProvider);
      if (currentUser == null) {
        ref.read(userSessionNotifierProvider.notifier).refreshProfile();
      }
      AmplitudeAnalytics.logScreenView('profile_edit_screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final User? user = ref.watch(userSessionNotifierProvider);

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
      body:
          user == null
              ? const Center(child: CircularProgressIndicator())
              : Builder(
                builder: (BuildContext context) {
                  final String nickname =
                      user.nickname.isNotEmpty
                          ? user.nickname
                          : user.displayName ?? '설정되지 않음';
                  final String bio = user.introduce ?? '자신을 소개해주세요';
                  final String gender = user.gender ?? '선택해주세요';
                  final String birthYear =
                      user.birthYear?.toString() ?? '선택해주세요';

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ProfileImageEditButton(
                            imageUrl: user.profileImageUrl ?? '',
                            onPressed: () {
                              AmplitudeAnalytics.logButtonClick(
                                'profile_image_edit',
                              );
                              _showProfileImageOptions();
                            },
                          ),

                          ProfileEditItem(
                            title: '닉네임',
                            currentValue: nickname,
                            onPressed: () => _navigateToNicknameEdit(),
                          ),

                          const SizedBox(height: 36),

                          ProfileEditItem(
                            title: '한 줄 소개',
                            currentValue: bio,
                            onPressed: () => _navigateToBioEdit(),
                          ),

                          const SizedBox(height: 36),

                          ProfileEditItem(
                            title: '성별',
                            currentValue: gender,
                            onPressed: () => _navigateToGenderEdit(),
                          ),

                          const SizedBox(height: 36),

                          ProfileEditItem(
                            title: '출생년도',
                            currentValue: birthYear,
                            onPressed: () => _navigateToBirthYearEdit(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  void _navigateToNicknameEdit() async {
    AmplitudeAnalytics.logButtonClick('profile_nickname_edit');
    final User? currentUser = ref.read(userSessionNotifierProvider);
    final String currentValue = currentUser?.nickname ?? '';

    final String? result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder:
            (BuildContext context) =>
                ProfileNicknameEditScreen(currentValue: currentValue),
      ),
    );

    if (result != null) {
      // 닉네임 수정 화면에서 이미 UseCase를 호출했으므로 UserSessionNotifier만 새로고침
      await ref.read(userSessionNotifierProvider.notifier).refreshProfile();
    }
  }

  void _navigateToBioEdit() async {
    AmplitudeAnalytics.logButtonClick('profile_bio_edit');
    final User? currentUser = ref.read(userSessionNotifierProvider);
    final String currentValue = currentUser?.introduce ?? '자신을 소개해주세요';

    final String? result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder:
            (BuildContext context) =>
                ProfileBioEditScreen(currentValue: currentValue),
      ),
    );

    if (result != null) {
      // 자기소개 수정 화면에서 이미 UseCase를 호출했으므로 UserSessionNotifier만 새로고침
      await ref.read(userSessionNotifierProvider.notifier).refreshProfile();
    }
  }

  void _navigateToGenderEdit() async {
    AmplitudeAnalytics.logButtonClick('profile_gender_edit');
    final User? currentUser = ref.read(userSessionNotifierProvider);
    final String currentValue = currentUser?.gender ?? '선택해주세요';

    final String? result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder:
            (BuildContext context) =>
                ProfileGenderEditScreen(currentValue: currentValue),
      ),
    );

    if (result != null) {
      // 성별 수정 화면에서 이미 UseCase를 호출했으므로 UserSessionNotifier만 새로고침
      await ref.read(userSessionNotifierProvider.notifier).refreshProfile();
    }
  }

  void _navigateToBirthYearEdit() async {
    AmplitudeAnalytics.logButtonClick('profile_birth_year_edit');
    final User? currentUser = ref.read(userSessionNotifierProvider);
    final String currentValue = currentUser?.birthYear?.toString() ?? '선택해주세요';

    final String? result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder:
            (BuildContext context) =>
                ProfileBirthYearEditScreen(currentValue: currentValue),
      ),
    );

    if (result != null) {
      // 생년월일 수정 화면에서 이미 UseCase를 호출했으므로 UserSessionNotifier만 새로고침
      await ref.read(userSessionNotifierProvider.notifier).refreshProfile();
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
            _takePhotoWithCamera();
          },
        ),
        PlatformActionSheetOption(
          title: '앨범에서 사진 선택',
          onSelected: () {
            AmplitudeAnalytics.logButtonClick('profile_image_gallery');
            _pickImageFromGallery();
          },
        ),
        PlatformActionSheetOption(
          title: '사진 삭제',
          onSelected: () {
            AmplitudeAnalytics.logButtonClick('profile_image_delete');
            _deleteProfileImage();
          },
          isDestructive: true,
        ),
      ],
    );
  }

  Future<void> _handleImageUpdate(XFile? image, String operation) async {
    if (image == null) return;

    try {
      final File imageFile = File(image.path);
      final UploadProfileImageUseCase uploadUseCase = ref.read(
        uploadProfileImageUseCaseProvider,
      );

      // UseCase를 통해 이미지 업로드
      final AppResult<User> result = await uploadUseCase.execute(imageFile);

      if (result is AppSuccess<User>) {
        final User updatedUser = result.data;

        await ref
            .read(userSessionNotifierProvider.notifier)
            .setUserSession(updatedUser);

        if (mounted) {
          showSuccessMessage(context, '프로필 사진이 성공적으로 업데이트되었습니다');
          setState(() {}); // UI 새로고침
        }
      } else if (result is AppFailure<User>) {
        _handleImageError(operation, result.exception);
      }
    } catch (e) {
      _handleImageError(operation, e);
    }
  }

  void _handleImageError(String operation, dynamic error) {
    if (mounted) {
      showErrorMessage(context, '업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      _handleImageUpdate(photo, '카메라 촬영');
    } catch (e) {
      _handleImageError('카메라 접근', e);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      await _handleImageUpdate(image, '갤러리 선택');
    } catch (e) {
      _handleImageError('갤러리 접근', e);
    }
  }

  void _deleteProfileImage() {
    // TODO: 프로필 사진 삭제 API 호출
    setState(() {
      // 기본 이미지로 설정
      // _profileImagePath = null;
    });

    showSuccessMessage(context, '성공적으로 업데이트 했습니다');
  }
}
