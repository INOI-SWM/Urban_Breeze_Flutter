import '../../domain/repositories/cycling_workout_repository.dart';

class CheckHealthKitPermissionsUseCase {
  const CheckHealthKitPermissionsUseCase(this._repository);
  final CyclingWorkoutRepository _repository;

  Future<bool> execute() async {
    return await _repository.hasPermissions();
  }
}
