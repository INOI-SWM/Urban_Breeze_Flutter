import 'dart:io';

import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/application/use_cases/base_profile_use_case.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';
import 'package:urban_breeze/shared/utils/image_upload_utils.dart';

class UploadProfileImageUseCase extends BaseProfileUseCase<File> {
  const UploadProfileImageUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  @override
  Future<AppResult<User>> execute(File input) async {
    try {
      // ImageUploadUtils를 사용하여 파일 검증
      ImageUploadUtils.validateFileSize(input, maxSizeInMB: 20);

      final String fileExtension = ImageUploadUtils.getFileExtension(
        input.path,
      );
      final String mimeType = ImageUploadUtils.getMimeTypeFromExtension(
        fileExtension,
      );

      if (!ImageUploadUtils.isSupportedImageType(mimeType)) {
        return const AppFailure<User>(
          ValidationException('지원하지 않는 이미지 형식입니다. JPG, PNG, WebP 형식을 사용해주세요'),
        );
      }

      return super.execute(input);
    } catch (e) {
      return AppFailure<User>(ValidationException(e.toString()));
    }
  }

  @override
  Future<User> performUpdate(File input) async {
    return _repository.uploadProfileImage(input);
  }

  @override
  String getErrorMessage() => '프로필 이미지 업로드에 실패했습니다';
}
