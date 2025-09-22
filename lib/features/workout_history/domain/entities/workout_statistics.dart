class WorkoutStatistics {
  const WorkoutStatistics({
    required this.period,
    required this.summary,
    required this.chartData,
  });

  final WorkoutStatisticsPeriod period;
  final WorkoutStatisticsSummary summary;
  final WorkoutStatisticsChartData chartData; // 그래프용 데이터

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutStatistics &&
        other.period == period &&
        other.summary == summary &&
        other.chartData == chartData;
  }

  @override
  int get hashCode => Object.hash(period, summary, chartData);

  @override
  String toString() {
    return 'WorkoutStatistics('
        'period: $period, '
        'summary: $summary, '
        'chartData: $chartData'
        ')';
  }
}

class WorkoutStatisticsPeriod {
  const WorkoutStatisticsPeriod({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.displayTitle,
  });

  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String displayTitle;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutStatisticsPeriod &&
        other.type == type &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.displayTitle == displayTitle;
  }

  @override
  int get hashCode => Object.hash(type, startDate, endDate, displayTitle);

  @override
  String toString() {
    return 'WorkoutStatisticsPeriod('
        'type: $type, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'displayTitle: $displayTitle'
        ')';
  }
}

class WorkoutStatisticsSummary {
  const WorkoutStatisticsSummary({
    required this.totalDistance,
    required this.totalElevationGain,
    required this.totalDuration,
    required this.totalActivityCount,
  });

  final double totalDistance; // km
  final double totalElevationGain; // m
  final Duration totalDuration;
  final int totalActivityCount; // 횟수

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutStatisticsSummary &&
        other.totalDistance == totalDistance &&
        other.totalElevationGain == totalElevationGain &&
        other.totalDuration == totalDuration &&
        other.totalActivityCount == totalActivityCount;
  }

  @override
  int get hashCode => Object.hash(
    totalDistance,
    totalElevationGain,
    totalDuration,
    totalActivityCount,
  );

  @override
  String toString() {
    return 'WorkoutStatisticsSummary('
        'totalDistance: $totalDistance km, '
        'totalElevationGain: $totalElevationGain km, '
        'totalDuration: $totalDuration, '
        'totalActivityCount: $totalActivityCount'
        ')';
  }
}

class WorkoutStatisticsChartData {
  const WorkoutStatisticsChartData({
    required this.distancePoints,
    required this.elevationPoints,
    required this.durationPoints,
  });

  final List<WorkoutStatisticsChartPoint> distancePoints;
  final List<WorkoutStatisticsChartPoint> elevationPoints;
  final List<WorkoutStatisticsChartPoint> durationPoints;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutStatisticsChartData &&
        _listEquals(other.distancePoints, distancePoints) &&
        _listEquals(other.elevationPoints, elevationPoints) &&
        _listEquals(other.durationPoints, durationPoints);
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(distancePoints, elevationPoints, durationPoints);

  @override
  String toString() {
    return 'WorkoutStatisticsChartData('
        'distancePoints: ${distancePoints.length}, '
        'elevationPoints: ${elevationPoints.length}, '
        'durationPoints: ${durationPoints.length}'
        ')';
  }
}

class WorkoutStatisticsChartPoint {
  const WorkoutStatisticsChartPoint({required this.label, required this.value});

  final String label; // x축 라벨 (날짜)
  final double value; // y축 값 (거리 km, 상승고도 m, 시간 분)

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutStatisticsChartPoint &&
        other.label == label &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(label, value);

  @override
  String toString() {
    return 'WorkoutStatisticsChartPoint(label: $label, value: $value)';
  }
}
