import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/exceptions/validation_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/workout_history_repository.dart';

class UpdateWorkoutTitleUseCase {
  const UpdateWorkoutTitleUseCase({required this.repository});

  final WorkoutHistoryRepository repository;

  static const int _maxTitleLength = 60;

  Future<AppResult<WorkoutDetail>> execute({
    required String workoutId,
    required String title,
    required WorkoutDetail currentWorkoutDetail,
  }) async {
    // 유효성 검사
    final AppResult<void>? validationResult = _validateInputs(workoutId, title);
    if (validationResult != null) {
      return AppFailure<WorkoutDetail>(
        (validationResult as AppFailure<void>).exception,
      );
    }

    // Repository 호출
    try {
      await repository.updateWorkoutTitle(workoutId: workoutId, title: title);
      // 업데이트된 WorkoutDetail 객체 반환
      final WorkoutDetail updatedWorkoutDetail = currentWorkoutDetail.copyWith(
        title: title,
      );
      return AppSuccess<WorkoutDetail>(updatedWorkoutDetail);
    } catch (e) {
      return _handleRepositoryError(e);
    }
  }

  AppResult<void>? _validateInputs(String workoutId, String title) {
    if (workoutId.trim().isEmpty) {
      return const AppFailure<void>(
        ValidationException(code: 'WORKOUT_ID_EMPTY'),
      );
    }

    if (title.trim().isEmpty) {
      return const AppFailure<void>(ValidationException(code: 'TITLE_EMPTY'));
    }

    if (title.length > _maxTitleLength) {
      return const AppFailure<void>(
        ValidationException(
          code: 'TITLE_TOO_LONG',
          data: <String, dynamic>{'maxLength': _maxTitleLength},
        ),
      );
    }

    return null;
  }

  AppResult<WorkoutDetail> _handleRepositoryError(dynamic error) {
    if (error is BaseDomainException) {
      return AppFailure<WorkoutDetail>(error);
    }

    // 예상치 못한 에러 타입에 대한 처리
    return AppFailure<WorkoutDetail>(
      Exception('Failed to update workout title: ${error.toString()}')
          as BaseDomainException,
    );
  }
}
