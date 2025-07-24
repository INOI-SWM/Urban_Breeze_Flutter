class WorkoutStatistics {
  const WorkoutStatistics({
    required this.period,
    required this.summary,
    required this.details,
  });

  final WorkoutStatisticsPeriod period;
  final WorkoutStatisticsSummary summary;
  final List<WorkoutStatisticsDetail> details; // 그래프용 데이터

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutStatistics &&
        other.period == period &&
        other.summary == summary &&
        other.details.length == details.length &&
        _listEquals(other.details, details);
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(period, summary, details);

  @override
  String toString() {
    return 'WorkoutStatistics('
        'period: $period, '
        'summary: $summary, '
        'details: ${details.length} items'
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
  final int totalElevationGain; // m
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
        'totalElevationGain: $totalElevationGain m, '
        'totalDuration: $totalDuration, '
        'totalActivityCount: $totalActivityCount'
        ')';
  }
}

class WorkoutStatisticsDetailValue {
  const WorkoutStatisticsDetailValue({
    required this.distance,
    required this.elevationGain,
    required this.duration,
  });

  final double distance; // km
  final int elevationGain; // m
  final Duration duration;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutStatisticsDetailValue &&
        other.distance == distance &&
        other.elevationGain == elevationGain &&
        other.duration == duration;
  }

  @override
  int get hashCode => Object.hash(distance, elevationGain, duration);

  @override
  String toString() {
    return 'WorkoutStatisticsDetailValue('
        'distance: $distance km, '
        'elevationGain: $elevationGain m, '
        'duration: $duration'
        ')';
  }
}

class WorkoutStatisticsDetail {
  const WorkoutStatisticsDetail({required this.label, required this.value});

  final String label; // x축 라벨 (날짜)
  final WorkoutStatisticsDetailValue value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutStatisticsDetail &&
        other.label == label &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(label, value);

  @override
  String toString() {
    return 'WorkoutStatisticsDetail(label: $label, value: $value)';
  }
}
