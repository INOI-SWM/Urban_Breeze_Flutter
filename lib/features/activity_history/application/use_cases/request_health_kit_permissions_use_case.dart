import '../../domain/repositories/cycling_workout_repository.dart';

class RequestHealthKitPermissionsUseCase {
  const RequestHealthKitPermissionsUseCase(this._repository);
  final CyclingWorkoutRepository _repository;

  Future<bool> execute() async {
    return await _repository.requestPermissions();
  }
}
