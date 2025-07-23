class WorkoutFormatter {
  WorkoutFormatter._();

  /// 거리를 km 단위 문자열로 변환 (미터 → "0.0 km")
  static String toKmText(double distanceInMeters) {
    return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
  }

  /// 시간을 분/초 문자열로 변환 ("0분 0초")
  static String toDurationText(Duration duration) {
    return '${duration.inMinutes}분 ${duration.inSeconds % 60}초';
  }

  /// 속도를 km/h 문자열로 변환 ("0.0 km/h")
  static String toSpeedText(double distanceInMeters, Duration duration) {
    final double kmPerHour =
        distanceInMeters / 1000 / (duration.inMinutes / 60);
    return '${kmPerHour.toStringAsFixed(1)} km/h';
  }

  /// 칼로리를 kcal 문자열로 변환 ("000 kcal")
  static String toCaloriesText(double calories) {
    return '${calories.round()} kcal';
  }

  /// 심박수를 bpm 문자열로 변환 ("000 bpm" 또는 "-- bpm")
  static String toHeartRateText(double heartRate) {
    return heartRate > 0 ? '${heartRate.round()} bpm' : '-- bpm';
  }
}
