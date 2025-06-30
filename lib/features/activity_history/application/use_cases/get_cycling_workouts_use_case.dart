import '../../domain/entities/cycling_workout_record.dart';
import '../../domain/repositories/cycling_workout_repository.dart';

class GetCyclingWorkoutsUseCase {
  const GetCyclingWorkoutsUseCase(this._repository);
  final CyclingWorkoutRepository _repository;

  Future<List<CyclingWorkoutRecord>> execute({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    return await _repository.getCyclingWorkouts(
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }
}
