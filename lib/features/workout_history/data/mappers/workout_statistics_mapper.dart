import '../../domain/entities/workout_statistics.dart';
import '../models/workout_statistics_response_model.dart';

class WorkoutStatisticsMapper {
  static WorkoutStatistics toEntity(WorkoutStatisticsResponseModel model) {
    return WorkoutStatistics(
      period: _mapPeriod(model.period),
      summary: _mapSummary(model.summary),
      chartData: _mapChartData(model.details),
      oldestActivityDate:
          model.oldestActivityDate != null
              ? DateTime.parse(model.oldestActivityDate!)
              : null,
    );
  }

  static WorkoutStatisticsPeriod _mapPeriod(
    WorkoutStatisticsPeriodModel model,
  ) {
    return WorkoutStatisticsPeriod(
      type: model.type,
      startDate: DateTime.parse(model.startDate),
      endDate: DateTime.parse(model.endDate),
      displayTitle: model.displayTitle,
    );
  }

  static WorkoutStatisticsSummary _mapSummary(
    WorkoutStatisticsSummaryModel model,
  ) {
    return WorkoutStatisticsSummary(
      totalDistance: model.totalDistance,
      totalElevationGain: model.totalElevationGain,
      totalDuration: Duration(seconds: model.totalDuration), // 초를 Duration으로 변환
      totalActivityCount: model.totalActivityCount,
    );
  }

  static WorkoutStatisticsChartData _mapChartData(
    List<WorkoutStatisticsDetailModel> details,
  ) {
    final List<WorkoutStatisticsChartPoint> distancePoints =
        <WorkoutStatisticsChartPoint>[];
    final List<WorkoutStatisticsChartPoint> elevationPoints =
        <WorkoutStatisticsChartPoint>[];
    final List<WorkoutStatisticsChartPoint> durationPoints =
        <WorkoutStatisticsChartPoint>[];

    for (final WorkoutStatisticsDetailModel detail in details) {
      distancePoints.add(
        WorkoutStatisticsChartPoint(
          label: detail.label,
          value: detail.value.distanceKm,
        ),
      );

      elevationPoints.add(
        WorkoutStatisticsChartPoint(
          label: detail.label,
          value: detail.value.elevationGainM.toDouble(),
        ),
      );

      durationPoints.add(
        WorkoutStatisticsChartPoint(
          label: detail.label,
          value: detail.value.durationSec / 60.0, // 초 → 분
        ),
      );
    }

    return WorkoutStatisticsChartData(
      distancePoints: distancePoints,
      elevationPoints: elevationPoints,
      durationPoints: durationPoints,
    );
  }
}
