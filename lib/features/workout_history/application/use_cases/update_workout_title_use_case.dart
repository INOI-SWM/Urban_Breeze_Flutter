import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/exceptions/validation_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/workout_history_repository.dart';

class UpdateWorkoutTitleUseCase {
  const UpdateWorkoutTitleUseCase({required this.repository});

  final WorkoutHistoryRepository repository;

  static const int _maxTitleLength = 60;

  Future<AppResult<void>> execute({
    required String workoutId,
    required String title,
  }) async {
    // 유효성 검사
    final AppResult<void>? validationResult = _validateInputs(workoutId, title);
    if (validationResult != null) {
      return validationResult;
    }

    // Repository 호출
    try {
      await repository.updateWorkoutTitle(workoutId: workoutId, title: title);
      return const AppSuccess<void>(null);
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

  AppResult<void> _handleRepositoryError(dynamic error) {
    if (error is BaseDomainException) {
      return AppFailure<void>(error);
    }

    // 예상치 못한 에러 타입에 대한 처리
    return AppFailure<void>(
      Exception('Failed to update workout title: ${error.toString()}')
          as BaseDomainException,
    );
  }
}
