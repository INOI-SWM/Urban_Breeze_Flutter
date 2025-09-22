import 'dart:io';

import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/exceptions/validation_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/activity_image.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/workout_history_repository.dart';

class UploadWorkoutImagesUseCase {
  const UploadWorkoutImagesUseCase({required this.repository});

  final WorkoutHistoryRepository repository;

  Future<AppResult<List<ActivityImage>>> execute({
    required String activityId,
    required List<File> imageFiles,
  }) async {
    try {
      // 빈 리스트 검증
      if (imageFiles.isEmpty) {
        return const AppFailure<List<ActivityImage>>(
          ValidationException(
            code: 'EMPTY_IMAGE_LIST',
            message: '업로드할 이미지를 선택해주세요',
          ),
        );
      }

      // 파일 개수 제한 (예: 최대 30개)
      if (imageFiles.length > 30) {
        return const AppFailure<List<ActivityImage>>(
          ValidationException(
            code: 'IMAGE_COUNT_EXCEEDED',
            message: '이미지는 최대 30개까지 업로드할 수 있습니다',
          ),
        );
      }

      // 각 파일 유효성 검사
      for (final File file in imageFiles) {
        if (!file.existsSync()) {
          return const AppFailure<List<ActivityImage>>(
            ValidationException(
              code: 'FILE_NOT_EXISTS',
              message: '존재하지 않는 파일이 포함되어 있습니다',
            ),
          );
        }

        // 파일 크기 검사 (20MB = 20 * 1024 * 1024 bytes)
        final int fileSize = file.lengthSync();
        const int maxSize = 20 * 1024 * 1024;
        if (fileSize > maxSize) {
          return const AppFailure<List<ActivityImage>>(
            ValidationException(
              code: 'FILE_SIZE_EXCEEDED',
              message: '이미지 파일은 20MB 이하여야 합니다',
            ),
          );
        }
      }

      final List<ActivityImage> uploadedImages = await repository
          .uploadWorkoutImages(activityId: activityId, imageFiles: imageFiles);

      return AppSuccess<List<ActivityImage>>(uploadedImages);
    } catch (e) {
      return AppFailure<List<ActivityImage>>(NetworkException(e.toString()));
    }
  }
}
