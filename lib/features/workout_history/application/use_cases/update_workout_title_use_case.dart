import 'package:ridingmate/core/exceptions/base_domain_exception.dart';

import '../../domain/exceptions/workout_history_domain_exceptions.dart';
import '../../domain/repositories/workout_history_repository.dart';

class UpdateWorkoutTitleUseCase {
  const UpdateWorkoutTitleUseCase({
    required WorkoutHistoryRepository workoutHistoryRepository,
  }) : _workoutHistoryRepository = workoutHistoryRepository;

  final WorkoutHistoryRepository _workoutHistoryRepository;

  Future<void> execute({
    required String workoutId,
    required String title,
  }) async {
    try {
      if (title.trim().isEmpty) {
        throw const ValidationException('제목은 비어있을 수 없습니다.');
      }

      await _workoutHistoryRepository.updateWorkoutTitle(
        workoutId: workoutId,
        title: title.trim(),
      );
    } catch (e) {
      if (e is WorkoutTitleUpdateException) {
        rethrow;
      }
      throw WorkoutTitleUpdateException('운동기록 제목 수정 중 오류가 발생했습니다: $e');
    }
  }
}
