import 'package:urban_breeze/features/workout_history/domain/entities/workout_list.dart';
import 'package:urban_breeze/features/workout_history/domain/enums/workout_sort_type.dart';

abstract class WorkoutHistoryRepository {
  Future<WorkoutList> getWorkoutList({
    int page = 0,
    int size = 10,
    WorkoutSortType sortType = WorkoutSortType.startedAtDesc,
  });

  Future<void> updateWorkoutTitle({
    required String workoutId,
    required String title,
  });
}
