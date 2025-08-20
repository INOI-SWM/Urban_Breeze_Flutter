import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/home/presentation/widgets/latest_workout_card.dart';
import 'package:urban_breeze/features/home/presentation/widgets/photo_banner.dart';
import 'package:urban_breeze/features/home/presentation/widgets/stats_summary_card.dart';
import 'package:urban_breeze/features/workout_history/presentation/pages/workout_history_page.dart';
import 'package:urban_breeze/navigation/navigation_providers.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

                    // 기록 통계 (더미 요약 카드)
                    StatsSummaryCard(
                      onMorePressed: () {
                        ref.read(workoutHistoryTabProvider.notifier).state =
                            WorkoutHistoryTab.statistics;
                        ref.read(bottomNavIndexProvider.notifier).state = 3;
                      },
                    ),
                    const SizedBox(height: 20),

                    // 최근 라이딩 1건
                    LatestWorkoutCard(
                      onMorePressed: () {
                        ref.read(workoutHistoryTabProvider.notifier).state =
                            WorkoutHistoryTab.ridingHistory;
                        ref.read(bottomNavIndexProvider.notifier).state = 3;
                      },
                    ),
                  ],
                ),
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
