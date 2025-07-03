abstract class AppleHealthKitException implements Exception {
  AppleHealthKitException(this.message);
  final String message;

  @override
  String toString() => 'HealthKitException: $message';
}

class HealthKitPermissionException extends AppleHealthKitException {
  HealthKitPermissionException(super.message);

  @override
  String toString() => 'HealthKitPermissionException: $message';
}

class HealthKitDataException extends AppleHealthKitException {
  HealthKitDataException(super.message);

  @override
  String toString() => 'HealthKitDataException: $message';
}

class HealthKitWorkoutNotFoundException extends AppleHealthKitException {
  HealthKitWorkoutNotFoundException(super.message);

  @override
  String toString() => 'HealthKitWorkoutNotFoundException: $message';
}
