import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/home/presentation/widgets/latest_workout_card.dart';
import 'package:urban_breeze/features/home/presentation/widgets/photo_banner.dart';
import 'package:urban_breeze/features/home/presentation/widgets/stats_summary_card.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

                    // 기록 통계 (더미 요약 카드)
                    StatsSummaryCard(
                      onMorePressed: () {
                        // TODO: 기록 - 통계 화면으로 이동
                        print('기록 - 통계 화면으로 이동');
                      },
                    ),
                    const SizedBox(height: 20),

                    // 최근 라이딩 1건
                    LatestWorkoutCard(
                      onMorePressed: () {
                        // TODO: 기록 - 데이터 화면으로 이동
                        print('기록 - 데이터 화면으로 이동');
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
