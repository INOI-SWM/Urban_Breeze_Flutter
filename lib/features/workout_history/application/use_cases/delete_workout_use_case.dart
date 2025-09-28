import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/workout_history_repository.dart';

class DeleteWorkoutUseCase {
  const DeleteWorkoutUseCase({required WorkoutHistoryRepository repository})
    : _repository = repository;

  final WorkoutHistoryRepository _repository;

  Future<AppResult<void>> execute(String activityId) async {
    try {
      await _repository.deleteWorkout(activityId);
      return const AppSuccess<void>(null);
    } on NetworkException catch (e) {
      return AppFailure<void>(e);
    } on ServerException catch (e) {
      return AppFailure<void>(e);
    } catch (e) {
      return AppFailure<void>(
        ServerException('운동기록 삭제에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
