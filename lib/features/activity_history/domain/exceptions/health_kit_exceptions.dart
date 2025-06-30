abstract class HealthKitException implements Exception {
  HealthKitException(this.message);
  final String message;

  @override
  String toString() => 'HealthKitException: $message';
}

class HealthKitPermissionException extends HealthKitException {
  HealthKitPermissionException(super.message);

  @override
  String toString() => 'HealthKitPermissionException: $message';
}

class HealthKitDataException extends HealthKitException {
  HealthKitDataException(super.message);

  @override
  String toString() => 'HealthKitDataException: $message';
}

class HealthKitWorkoutNotFoundException extends HealthKitException {
  HealthKitWorkoutNotFoundException(super.message);

  @override
  String toString() => 'HealthKitWorkoutNotFoundException: $message';
}
