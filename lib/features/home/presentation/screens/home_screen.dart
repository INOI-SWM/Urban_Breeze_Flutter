import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/home/presentation/widgets/latest_workout_card.dart';
import 'package:urban_breeze/features/home/presentation/widgets/photo_banner.dart';
import 'package:urban_breeze/features/home/presentation/widgets/stats_summary_card.dart';
import 'package:urban_breeze/shared/design_system/tokens/decorations/app_shadows.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_size.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_solid.dart';

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
                    const StatsSummaryCard(),
                    const SizedBox(height: 20),

                    // 최근 라이딩 1건
                    const LatestWorkoutCard(),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.backgroundElevatedNormal,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppShadows.instance.normal,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '개발자 테스트',
                            style: AppTextStyles.headline2.bold.copyWith(
                              color: colors.labelStrong,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ButtonSolid(
                            text: 'Crashlytics 강제 크래시',
                            size: ButtonSize.medium,
                            backgroundColor: colors.statusNegative,
                            textColor: colors.staticWhite,
                            onPressed:
                                () => FirebaseCrashlytics.instance.crash(),
                          ),
                        ],
                      ),
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
