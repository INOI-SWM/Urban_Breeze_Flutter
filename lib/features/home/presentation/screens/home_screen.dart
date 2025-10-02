import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/home/di/home_providers.dart';
import 'package:urban_breeze/features/home/domain/entities/home_statistics.dart';
import 'package:urban_breeze/features/home/domain/entities/latest_workout.dart';
import 'package:urban_breeze/features/home/domain/entities/recommended_courses_for_home.dart';
import 'package:urban_breeze/features/home/presentation/widgets/latest_workout_card.dart';
import 'package:urban_breeze/features/home/presentation/widgets/photo_banner.dart';
import 'package:urban_breeze/features/home/presentation/widgets/recommended_courses_section.dart';
import 'package:urban_breeze/features/home/presentation/widgets/stats_summary_card.dart';
import 'package:urban_breeze/features/workout_history/presentation/pages/workout_history_page.dart';
import 'package:urban_breeze/navigation/navigation_providers.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 홈 화면 진입 이벤트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView('home_screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: const CustomAppBar(
        title: 'Urban Breeze',
        centerTitle: false,
        titleTextSize: AppBarTitleSize.large,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    // 상단 사진 배너
                    const PhotoBanner(),
                    const SizedBox(height: 20),

                    // 기록 통계
                    Consumer(
                      builder: (
                        BuildContext context,
                        WidgetRef ref,
                        Widget? child,
                      ) {
                        final AsyncValue<HomeStatistics> statisticsAsync = ref
                            .watch(homeStatisticsProvider);
                        return statisticsAsync.when(
                          data:
                              (HomeStatistics statistics) => StatsSummaryCard(
                                statistics: statistics,
                                onMorePressed: () {
                                  AmplitudeAnalytics.logButtonClick(
                                    'home_stats_more',
                                  );
                                  ref
                                      .read(workoutHistoryTabProvider.notifier)
                                      .state = WorkoutHistoryTab.statistics;
                                  ref
                                      .read(bottomNavIndexProvider.notifier)
                                      .state = 3;
                                },
                              ),
                          loading: () => const StatsSummaryCard(),
                          error:
                              (Object error, StackTrace stack) =>
                                  const StatsSummaryCard(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // 최근 라이딩 1건
                    Consumer(
                      builder: (
                        BuildContext context,
                        WidgetRef ref,
                        Widget? child,
                      ) {
                        final AsyncValue<LatestWorkout?> latestWorkoutAsync =
                            ref.watch(latestWorkoutProvider);
                        return latestWorkoutAsync.when(
                          data:
                              (LatestWorkout? workout) => LatestWorkoutCard(
                                workout: workout,
                                onMorePressed: () {
                                  AmplitudeAnalytics.logButtonClick(
                                    'home_latest_workout_more',
                                  );
                                  ref
                                      .read(workoutHistoryTabProvider.notifier)
                                      .state = WorkoutHistoryTab.ridingHistory;
                                  ref
                                      .read(bottomNavIndexProvider.notifier)
                                      .state = 3;
                                },
                              ),
                          loading: () => const LatestWorkoutCard(),
                          error:
                              (Object error, StackTrace stack) =>
                                  const LatestWorkoutCard(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // 추천 코스 3개 섹션
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final AsyncValue<RecommendedCoursesForHome>
                  recommendedCoursesAsync = ref.watch(
                    recommendedCoursesForHomeProvider,
                  );
                  return recommendedCoursesAsync.when(
                    data:
                        (
                          RecommendedCoursesForHome courses,
                        ) => RecommendedCoursesSection(
                          courses: courses,
                          onMorePressed: () {
                            AmplitudeAnalytics.logButtonClick(
                              'home_recommended_courses_more',
                            );
                            ref.read(bottomNavIndexProvider.notifier).state = 1;
                          },
                        ),
                    loading: () => const RecommendedCoursesSection(),
                    error:
                        (Object error, StackTrace stack) =>
                            const RecommendedCoursesSection(),
                  );
                },
              ),

              // 메인 콘텐츠
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
