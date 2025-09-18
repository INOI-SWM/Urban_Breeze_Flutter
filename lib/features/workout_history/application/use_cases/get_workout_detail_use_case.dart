import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/workout_history_repository.dart';

class GetWorkoutDetailUseCase {
  const GetWorkoutDetailUseCase({required this.repository});

  final WorkoutHistoryRepository repository;

  Future<AppResult<WorkoutDetail>> execute({required String activityId}) async {
    try {
      final WorkoutDetail workoutDetail = await repository.getWorkoutDetail(
        activityId: activityId,
      );
      return AppSuccess<WorkoutDetail>(workoutDetail);
    } catch (e) {
      return AppFailure<WorkoutDetail>(NetworkException(e.toString()));
    }
  }
}
