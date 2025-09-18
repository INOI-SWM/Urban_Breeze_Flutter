import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_list.dart';
import 'package:urban_breeze/features/workout_history/domain/enums/workout_sort_type.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/workout_history_repository.dart';

class GetWorkoutListUseCase {
  const GetWorkoutListUseCase({required this.repository});

  final WorkoutHistoryRepository repository;

  Future<AppResult<WorkoutList>> execute({
    int page = 0,
    int size = 10,
    WorkoutSortType sortType = WorkoutSortType.startedAtDesc,
  }) async {
    try {
      final WorkoutList workoutList = await repository.getWorkoutList(
        page: page,
        size: size,
        sortType: sortType,
      );
      return AppSuccess<WorkoutList>(workoutList);
    } catch (e) {
      return AppFailure<WorkoutList>(NetworkException(e.toString()));
    }
  }
}
