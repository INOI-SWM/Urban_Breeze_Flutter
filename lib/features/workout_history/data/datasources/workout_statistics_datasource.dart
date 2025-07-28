import '../../domain/enums/statistic_enums.dart';
import '../models/workout_statistics_response_model.dart';
import 'mock_workout_statistics_data.dart';

// TODO: 추후 실제 API 호출로 교체
class WorkoutStatisticsDataSource {
  /// 기간별 운동 통계 데이터 조회
  Future<WorkoutStatisticsResponseModel> getWorkoutStatistics({
    required StatisticPeriodType periodType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // TODO: 실제 API 호출 구현

    final Map<String, dynamic> jsonData =
        MockWorkoutStatisticsData.getMockStatisticsData(periodType);
    return WorkoutStatisticsResponseModel.fromJson(jsonData);
  }
}
