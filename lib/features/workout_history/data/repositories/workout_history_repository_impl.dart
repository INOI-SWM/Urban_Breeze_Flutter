import 'package:urban_breeze/features/workout_history/data/models/workout_list_response_model.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_list.dart';
import 'package:urban_breeze/features/workout_history/domain/enums/workout_sort_type.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/workout_history_repository.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

import '../datasources/remote_workout_history_datasource.dart';
import '../mappers/workout_mapper.dart';

class WorkoutHistoryRepositoryImpl implements WorkoutHistoryRepository {
  const WorkoutHistoryRepositoryImpl({required this.remoteDataSource});

  final RemoteWorkoutHistoryDataSource remoteDataSource;

  @override
  Future<WorkoutList> getWorkoutList({
    int page = 0,
    int size = 10,
    WorkoutSortType sortType = WorkoutSortType.startedAtDesc,
  }) async {
    final ApiResponseModel<WorkoutListResponseModel> response =
        await remoteDataSource.getWorkoutList(
          page: page,
          size: size,
          sortType: sortType,
        );

    return WorkoutMapper.fromApiResponse(response);
  }

  @override
  Future<void> updateWorkoutTitle({
    required String workoutId,
    required String title,
  }) async {
    await remoteDataSource.updateWorkoutTitle(
      workoutId: workoutId,
      title: title,
    );
  }
}
