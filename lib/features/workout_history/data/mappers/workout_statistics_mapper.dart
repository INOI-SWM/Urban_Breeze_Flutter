import '../../domain/entities/workout_statistics.dart';
import '../models/workout_statistics_response_model.dart';

class WorkoutStatisticsMapper {
  /// Model을 Entity로 변환
  static WorkoutStatistics toEntity(WorkoutStatisticsResponseModel model) {
    return WorkoutStatistics(
      period: _mapPeriod(model.period),
      summary: _mapSummary(model.summary),
      details: model.details.map(_mapDetail).toList(),
    );
  }

  /// Period Model을 Entity로 변환
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

  /// Summary Model을 Entity로 변환
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

  /// Detail Model을 Entity로 변환
  static WorkoutStatisticsDetail _mapDetail(
    WorkoutStatisticsDetailModel model,
  ) {
    return WorkoutStatisticsDetail(
      label: model.label,
      value: _mapDetailValue(model.value),
    );
  }

  /// DetailValue Model을 Entity로 변환
  static WorkoutStatisticsDetailValue _mapDetailValue(
    WorkoutStatisticsDetailValueModel model,
  ) {
    return WorkoutStatisticsDetailValue(
      distance: model.distanceKm,
      elevationGain: model.elevationGainM,
      duration: Duration(seconds: model.durationSec), // 초를 Duration으로 변환
    );
  }
}
