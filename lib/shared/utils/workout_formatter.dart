class WorkoutFormatter {
  WorkoutFormatter._();

  /// 거리를 km 단위 문자열로 변환 (미터 → "0.0 km" 또는 "--")
  static String toKmText(double distanceInMeters) {
    return distanceInMeters > 0
        ? '${(distanceInMeters / 1000).toStringAsFixed(1)} km'
        : '--';
  }

  /// 시간을 동적 문자열로 변환 ("1시간 30분 45초", "30분 45초", "45초" 또는 "--")
  static String toDurationText(Duration duration) {
    if (duration.inSeconds <= 0) {
      return '--';
    }

    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else if (minutes > 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$seconds초';
    }
  }

  /// 속도를 km/h 문자열로 변환 ("0.0 km/h" 또는 "--")
  static String toSpeedText(double distanceInMeters, Duration duration) {
    if (distanceInMeters <= 0 || duration.inSeconds <= 0) {
      return '--';
    }
    final double kmPerHour =
        distanceInMeters / 1000 / (duration.inSeconds / 3600);
    return '${kmPerHour.toStringAsFixed(1)} km/h';
  }

  /// 칼로리를 kcal 문자열로 변환 ("000 kcal" 또는 "--")
  static String toCaloriesText(double calories) {
    return calories > 0 ? '${calories.round()} kcal' : '--';
  }

  /// 심박수를 bpm 문자열로 변환 ("000 bpm" 또는 "--")
  static String toHeartRateText(double heartRate) {
    return heartRate > 0 ? '${heartRate.round()} bpm' : '--';
  }

  /// 고도를 m 문자열로 변환 ("000 m" 또는 "--")
  static String toAltitudeText(double? altitude) {
    return altitude != null && altitude > 0 ? '${altitude.round()} m' : '--';
  }

  /// 케이던스를 rpm 문자열로 변환 ("000 rpm" 또는 "--")
  static String toCadenceText(double? cadence) {
    return cadence != null && cadence > 0 ? '${cadence.round()} rpm' : '--';
  }

  /// 파워를 W 문자열로 변환 ("000 W" 또는 "--")
  static String toPowerText(double? power) {
    return power != null && power > 0 ? '${power.round()} W' : '--';
  }

  /// 최고속도를 km/h 문자열로 변환 ("0.0 km/h" 또는 "--")
  static String toMaxSpeedText(double? maxSpeed) {
    return maxSpeed != null && maxSpeed > 0
        ? '${maxSpeed.toStringAsFixed(1)} km/h'
        : '--';
  }
}
