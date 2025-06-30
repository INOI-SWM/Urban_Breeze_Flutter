import '../../domain/entities/cycling_workout_record.dart';
import '../../domain/repositories/cycling_workout_repository.dart';

class GetCyclingWorkoutByIdUseCase {
  const GetCyclingWorkoutByIdUseCase(this._repository);
  final CyclingWorkoutRepository _repository;

  Future<CyclingWorkoutRecord> execute(String id) async {
    return await _repository.getCyclingWorkoutById(id);
  }
}
