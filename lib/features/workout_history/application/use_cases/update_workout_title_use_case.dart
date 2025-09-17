import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/workout_history_repository.dart';

class UpdateWorkoutTitleUseCase {
  const UpdateWorkoutTitleUseCase({required this.repository});

  final WorkoutHistoryRepository repository;

  Future<AppResult<void>> execute({
    required String workoutId,
    required String title,
  }) async {
    // 입력 검증
    if (workoutId.isEmpty) {
      return AppFailure<void>(
        ArgumentError('Workout ID cannot be empty') as BaseDomainException,
      );
    }

    if (title.isEmpty) {
      return AppFailure<void>(
        ArgumentError('Title cannot be empty') as BaseDomainException,
      );
    }

    if (title.length > 100) {
      return AppFailure<void>(
        ArgumentError('Title cannot exceed 100 characters')
            as BaseDomainException,
      );
    }

    // Repository 호출
    try {
      await repository.updateWorkoutTitle(workoutId: workoutId, title: title);
      return const AppSuccess<void>(null);
    } catch (e) {
      return AppFailure<void>(e as BaseDomainException);
    }
  }
}
