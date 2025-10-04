class DisplayFormatter {
  DisplayFormatter._();

  /// 거리 표시용 문자열 반환 km
  /// 0일 때: "0km", 100km 이상: 소수점 없음, 10km 이상: 소수점 두자리, 10km 미만: 소수점 두자리
  static String formatDistance(double distance) {
    if (distance == 0) {
      return '0km';
    } else if (distance >= 100) {
      return '${distance.toStringAsFixed(0)}km';
    } else if (distance >= 10) {
      return '${distance.toStringAsFixed(2)}km'; // 소수점 두 자리로 변경
    } else {
      return '${distance.toStringAsFixed(2)}km';
    }
  }

  /// 거리 표시용 문자열 반환 (미터 → km)
  /// API에서 미터 단위로 받아서 km로 표시
  static String formatDistanceFromMeters(double distanceInMeters) {
    final double distanceInKm = distanceInMeters / 1000;
    return formatDistance(distanceInKm);
  }

  /// 상승 고도 표시용 문자열 반환 m
  /// 0일 때: "--", 100m 이상: 소수점 없음, 10m 이상: 소수점 한자리, 10m 미만: 소수점 두자리
  /// null일 때는 "--" 반환
  static String formatElevationGain(double? elevationGain) {
    if (elevationGain == null || elevationGain == 0) return '--';

    if (elevationGain >= 100) {
      return '${elevationGain.toStringAsFixed(0)}m';
    } else if (elevationGain >= 10) {
      return '${elevationGain.toStringAsFixed(1)}m';
    } else {
      return '${elevationGain.toStringAsFixed(2)}m';
    }
  }

  /// 운동 시간 표시용 문자열 반환 (시간:분 형식)
  /// 초 단위를 받아서 시간:분 형식으로 변환
  static String formatDurationFromSeconds(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// 운동 시간 표시용 문자열 반환 (시간:분 형식)
  /// 분 단위를 받아서 시간:분 형식으로 변환
  static String formatDurationFromMinutes(int minutes) {
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    }
    return '${remainingMinutes}m';
  }

  /// 날짜 표시용 문자열 반환 (YYYY-MM-DD 형식)
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
