import '../../domain/entities/heart_rate_data.dart';
import '../../domain/repositories/cycling_workout_repository.dart';

class GetWorkoutHeartRateDataUseCase {
  const GetWorkoutHeartRateDataUseCase(this._repository);
  final CyclingWorkoutRepository _repository;

  Future<List<HeartRateData>> execute({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  }) async {
    return await _repository.getHeartRateDataForWorkout(
      workoutStartTime: workoutStartTime,
      workoutEndTime: workoutEndTime,
    );
  }
}
