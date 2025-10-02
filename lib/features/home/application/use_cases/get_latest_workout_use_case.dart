import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/home/domain/entities/latest_workout.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/get_workout_list_use_case.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_activity.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_list.dart';
import 'package:urban_breeze/features/workout_history/domain/enums/workout_sort_type.dart';

class GetLatestWorkoutUseCase {
  const GetLatestWorkoutUseCase({required this.getWorkoutListUseCase});

  final GetWorkoutListUseCase getWorkoutListUseCase;

  Future<LatestWorkout?> execute() async {
    // 최근 운동 1개만 조회
    final AppResult<WorkoutList> result = await getWorkoutListUseCase.execute(
      page: 0,
      size: 1,
      sortType: WorkoutSortType.startedAtDesc,
    );

    if (result.isFailure) {
      return null;
    }

    final WorkoutList? workoutList = result.dataOrNull;
    if (workoutList == null || workoutList.activities.isEmpty) {
      return null;
    }

    final WorkoutActivity workout = workoutList.activities.first;
    return LatestWorkout(
      id: workout.activityId,
      title: workout.title,
      distance: workout.distance,
      duration: workout.duration,
      startedAt: workout.startedAt,
      thumbnailImageUrl: workout.thumbnailImageUrl,
      elevationGain: workout.elevationGain,
    );
  }
}
