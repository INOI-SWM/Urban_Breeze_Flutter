import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/workout_history_repository.dart';

class DeleteWorkoutImageUseCase {
  const DeleteWorkoutImageUseCase({required this.repository});

  final WorkoutHistoryRepository repository;

  Future<AppResult<void>> execute({
    required String activityId,
    required int imageId,
  }) async {
    try {
      // // 입력값 검증
      // if (activityId.isEmpty) {
      //   return const AppFailure<void>(
      //     ValidationException(
      //       code: 'INVALID_ACTIVITY_ID',
      //       message: '워크아웃 ID가 유효하지 않습니다',
      //     ),
      //   );
      // }

      // if (imageId <= 0) {
      //   return const AppFailure<void>(
      //     ValidationException(
      //       code: 'INVALID_IMAGE_ID',
      //       message: '이미지 ID가 유효하지 않습니다',
      //     ),
      //   );
      // }

      await repository.deleteWorkoutImage(
        activityId: activityId,
        imageId: imageId,
      );

      return const AppSuccess<void>(null);
    } catch (e) {
      return AppFailure<void>(NetworkException(e.toString()));
    }
  }
}
