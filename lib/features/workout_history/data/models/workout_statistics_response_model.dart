class WorkoutStatisticsPeriodModel {
  factory WorkoutStatisticsPeriodModel.fromJson(Map<String, dynamic> json) {
    return WorkoutStatisticsPeriodModel(
      type: json['type'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      displayTitle: json['displayTitle'] as String,
    );
  }
  const WorkoutStatisticsPeriodModel({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.displayTitle,
  });

  final String type;
  final String startDate;
  final String endDate;
  final String displayTitle;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'startDate': startDate,
      'endDate': endDate,
      'displayTitle': displayTitle,
    };
  }
}

class WorkoutStatisticsSummaryModel {
  factory WorkoutStatisticsSummaryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutStatisticsSummaryModel(
      totalDistance: json['totalDistance'] as double,
      totalElevationGain: json['totalElevationGain'] as double,
      totalDuration: json['totalDuration'] as int,
      totalActivityCount: json['totalActivityCount'] as int,
    );
  }
  const WorkoutStatisticsSummaryModel({
    required this.totalDistance,
    required this.totalElevationGain,
    required this.totalDuration,
    required this.totalActivityCount,
  });

  final double totalDistance; // km
  final double totalElevationGain; // m
  final int totalDuration; // 초
  final int totalActivityCount;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'totalDistance': totalDistance,
      'totalElevationGain': totalElevationGain,
      'totalDuration': totalDuration,
      'totalActivityCount': totalActivityCount,
    };
  }
}

class WorkoutStatisticsDetailValueModel {
  factory WorkoutStatisticsDetailValueModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WorkoutStatisticsDetailValueModel(
      distanceKm: json['distanceKm'] as double,
      elevationGainM: json['elevationGainM'] as double,
      durationSec: json['durationSec'] as int,
    );
  }
  const WorkoutStatisticsDetailValueModel({
    required this.distanceKm,
    required this.elevationGainM,
    required this.durationSec,
  });

  final double distanceKm;
  final double elevationGainM;
  final int durationSec;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'distanceKm': distanceKm,
      'elevationGainM': elevationGainM,
      'durationSec': durationSec,
    };
  }
}

class WorkoutStatisticsDetailModel {
  factory WorkoutStatisticsDetailModel.fromJson(Map<String, dynamic> json) {
    return WorkoutStatisticsDetailModel(
      label: json['label'] as String,
      value: WorkoutStatisticsDetailValueModel.fromJson(
        json['value'] as Map<String, dynamic>,
      ),
    );
  }
  const WorkoutStatisticsDetailModel({
    required this.label,
    required this.value,
  });

  final String label; // x축 라벨 (날짜)
  final WorkoutStatisticsDetailValueModel value;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'label': label, 'value': value.toJson()};
  }
}

class WorkoutStatisticsResponseModel {
  // 그래프용 데이터

  factory WorkoutStatisticsResponseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutStatisticsResponseModel(
      period: WorkoutStatisticsPeriodModel.fromJson(
        json['period'] as Map<String, dynamic>,
      ),
      summary: WorkoutStatisticsSummaryModel.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      details:
          (json['details'] as List<dynamic>)
              .map(
                (dynamic detail) => WorkoutStatisticsDetailModel.fromJson(
                  detail as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
  const WorkoutStatisticsResponseModel({
    required this.period,
    required this.summary,
    required this.details,
  });

  final WorkoutStatisticsPeriodModel period;
  final WorkoutStatisticsSummaryModel summary;
  final List<WorkoutStatisticsDetailModel> details;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'period': period.toJson(),
      'summary': summary.toJson(),
      'details':
          details
              .map((WorkoutStatisticsDetailModel detail) => detail.toJson())
              .toList(),
    };
  }
}
