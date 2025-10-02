import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/features/home/application/use_cases/get_home_statistics_use_case.dart';
import 'package:urban_breeze/features/home/application/use_cases/get_latest_workout_use_case.dart';
import 'package:urban_breeze/features/home/application/use_cases/get_recommended_courses_for_home_use_case.dart';
import 'package:urban_breeze/features/home/domain/entities/home_statistics.dart';
import 'package:urban_breeze/features/home/domain/entities/latest_workout.dart';
import 'package:urban_breeze/features/home/domain/entities/recommended_courses_for_home.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/get_recommended_course_list_usecase.dart';
import 'package:urban_breeze/features/recommended_course/di/recommended_course_providers.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/get_workout_list_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/get_workout_statistics_use_case.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';

/// 홈 화면 통계 데이터 Provider
final FutureProvider<HomeStatistics> homeStatisticsProvider =
    FutureProvider<HomeStatistics>((
      FutureProviderRef<HomeStatistics> ref,
    ) async {
      final GetHomeStatisticsUseCase useCase = ref.read(
        getHomeStatisticsUseCaseProvider,
      );
      return await useCase.execute();
    });

/// 최근 운동 데이터 Provider
final FutureProvider<LatestWorkout?> latestWorkoutProvider =
    FutureProvider<LatestWorkout?>((
      FutureProviderRef<LatestWorkout?> ref,
    ) async {
      final GetLatestWorkoutUseCase useCase = ref.read(
        getLatestWorkoutUseCaseProvider,
      );
      return await useCase.execute();
    });

/// 홈 화면용 추천 코스 데이터 Provider
final FutureProvider<RecommendedCoursesForHome>
recommendedCoursesForHomeProvider = FutureProvider<RecommendedCoursesForHome>((
  FutureProviderRef<RecommendedCoursesForHome> ref,
) async {
  final GetRecommendedCoursesForHomeUseCase useCase = ref.read(
    getRecommendedCoursesForHomeUseCaseProvider,
  );
  return await useCase.execute();
});

/// Use Case Providers
final Provider<GetHomeStatisticsUseCase> getHomeStatisticsUseCaseProvider =
    Provider<GetHomeStatisticsUseCase>((
      ProviderRef<GetHomeStatisticsUseCase> ref,
    ) {
      final GetWorkoutStatisticsUseCase getWorkoutStatisticsUseCase = ref.watch(
        getWorkoutStatisticsUseCaseProvider,
      );
      return GetHomeStatisticsUseCase(
        getWorkoutStatisticsUseCase: getWorkoutStatisticsUseCase,
      );
    });

final Provider<GetLatestWorkoutUseCase> getLatestWorkoutUseCaseProvider =
    Provider<GetLatestWorkoutUseCase>((
      ProviderRef<GetLatestWorkoutUseCase> ref,
    ) {
      final GetWorkoutListUseCase getWorkoutListUseCase = ref.watch(
        getWorkoutListUseCaseProvider,
      );
      return GetLatestWorkoutUseCase(
        getWorkoutListUseCase: getWorkoutListUseCase,
      );
    });

final Provider<GetRecommendedCoursesForHomeUseCase>
getRecommendedCoursesForHomeUseCaseProvider =
    Provider<GetRecommendedCoursesForHomeUseCase>((
      ProviderRef<GetRecommendedCoursesForHomeUseCase> ref,
    ) {
      final GetRecommendedCourseListUseCase getRecommendedCourseListUseCase =
          ref.watch(getRecommendedCourseListUseCaseProvider);
      return GetRecommendedCoursesForHomeUseCase(
        getRecommendedCourseListUseCase: getRecommendedCourseListUseCase,
      );
    });
