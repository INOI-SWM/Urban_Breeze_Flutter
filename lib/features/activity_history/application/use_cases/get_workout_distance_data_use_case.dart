import '../../domain/entities/distance_data.dart';
import '../../domain/repositories/cycling_workout_repository.dart';

class GetWorkoutDistanceDataUseCase {
  const GetWorkoutDistanceDataUseCase(this._repository);
  final CyclingWorkoutRepository _repository;

  Future<List<DistanceData>> execute({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  }) async {
    return await _repository.getDistanceDataForWorkout(
      workoutStartTime: workoutStartTime,
      workoutEndTime: workoutEndTime,
    );
  }
}
