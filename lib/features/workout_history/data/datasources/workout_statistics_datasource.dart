import 'package:http/http.dart' as http;
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

import '../../domain/enums/statistic_enums.dart';
import '../models/workout_statistics_response_model.dart';
import '../utils/statistics_date_utils.dart';

class RemoteWorkoutStatisticsDataSource extends BaseRemoteDataSource {
  RemoteWorkoutStatisticsDataSource({super.client});

  /// 기간별 운동 통계 데이터 조회
  Future<ApiResponseModel<WorkoutStatisticsResponseModel>>
  getWorkoutStatistics({
    required StatisticPeriodType periodType,
    required int year,
    int? month,
    int? week,
  }) async {
    try {
      // 날짜 범위 계산
      final DateRange dateRange = StatisticsDateUtils.calculateDateRange(
        periodType: periodType,
        year: year,
        month: month,
        week: week,
      );

      // API 쿼리 파라미터 생성
      final Map<String, String> queryParams = dateRange.toApiParams(periodType);

      // API 호출
      final http.Response response = await get(
        ApiEndpoints.workoutStatistics,
        queryParameters: queryParams,
      );

      final Map<String, dynamic> responseData = decodeResponse(response);

      return ApiResponseModel<WorkoutStatisticsResponseModel>.fromJson(
        responseData,
        (Map<String, dynamic> json) =>
            WorkoutStatisticsResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
