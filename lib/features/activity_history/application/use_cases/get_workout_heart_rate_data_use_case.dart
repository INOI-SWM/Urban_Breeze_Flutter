import '../../domain/entities/heart_rate_data.dart';
import '../../domain/repositories/cycling_workout_repository.dart';

class GetWorkoutHeartRateDataUseCase {
  const GetWorkoutHeartRateDataUseCase(this._repository);
  final CyclingWorkoutRepository _repository;

  Future<List<HeartRateData>> execute(String workoutId) async {
    return await _repository.getHeartRateData(workoutId);
  }
}
