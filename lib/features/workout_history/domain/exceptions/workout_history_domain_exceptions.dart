abstract class WorkoutHistoryDomainException implements Exception {
  const WorkoutHistoryDomainException(this.message);
  final String message;

  @override
  String toString() => 'WorkoutHistoryDomainException: $message';
}

/// 네트워크 문제
class WorkoutHistoryNetworkException extends WorkoutHistoryDomainException {
  const WorkoutHistoryNetworkException(super.message);

  @override
  String toString() => 'WorkoutHistoryNetworkException: $message';
}

/// 서버 문제
class WorkoutHistoryServerException extends WorkoutHistoryDomainException {
  const WorkoutHistoryServerException(super.message);

  @override
  String toString() => 'WorkoutHistoryServerException: $message';
}

/// 데이터 파싱 문제
class WorkoutHistoryParsingException extends WorkoutHistoryDomainException {
  const WorkoutHistoryParsingException(super.message);

  @override
  String toString() => 'WorkoutHistoryParsingException: $message';
}

/// 운동기록 제목 업데이트 문제
class WorkoutTitleUpdateException extends WorkoutHistoryDomainException {
  const WorkoutTitleUpdateException(super.message);

  @override
  String toString() => 'WorkoutTitleUpdateException: $message';
}

/// 운동기록 유효성 검증 문제
class WorkoutHistoryValidationException extends WorkoutHistoryDomainException {
  const WorkoutHistoryValidationException(super.message);

  @override
  String toString() => 'WorkoutHistoryValidationException: $message';
}
