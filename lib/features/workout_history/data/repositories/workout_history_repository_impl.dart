import '../../domain/repositories/workout_history_repository.dart';
import '../datasources/remote_workout_history_datasource.dart';

class WorkoutHistoryRepositoryImpl implements WorkoutHistoryRepository {
  const WorkoutHistoryRepositoryImpl({required this.remoteDataSource});

  final RemoteWorkoutHistoryDatasource remoteDataSource;

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
