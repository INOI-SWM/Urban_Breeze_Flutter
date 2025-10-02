import 'package:urban_breeze/features/home/domain/entities/home_statistics.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/get_workout_statistics_use_case.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/period_selection.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_statistics.dart';
import 'package:urban_breeze/features/workout_history/domain/enums/statistic_enums.dart';
import 'package:urban_breeze/shared/utils/period_utils.dart';

class GetHomeStatisticsUseCase {
  const GetHomeStatisticsUseCase({required this.getWorkoutStatisticsUseCase});

  final GetWorkoutStatisticsUseCase getWorkoutStatisticsUseCase;

  Future<HomeStatistics> execute() async {
    // 이번 주 통계 조회
    final DateTime now = DateTime.now();
    final PeriodSelection periodSelection = PeriodSelection(
      year: now.year,
      month: now.month,
      week: PeriodUtils.getWeekOfMonth(now),
    );

    final WorkoutStatistics statistics = await getWorkoutStatisticsUseCase
        .execute(
          periodType: StatisticPeriodType.week,
          periodSelection: periodSelection,
        );

    return HomeStatistics(
      totalDistance: statistics.summary.totalDistance,
      totalDuration: statistics.summary.totalDuration.inSeconds,
      totalWorkouts: statistics.summary.totalActivityCount,
    );
  }
}
