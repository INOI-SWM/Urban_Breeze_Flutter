import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/route_planning/presentation/widgets/route_stats_row.dart';
import 'package:urban_breeze/navigation/navigation_scaffold.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_size.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_solid.dart';

class RouteCreateCompleteScreen extends StatelessWidget {
  const RouteCreateCompleteScreen({
    super.key,
    required this.routeTitle,
    required this.totalDistance,
    required this.totalDuration,
    required this.elevationGain,
  });

  final String routeTitle;
  final String totalDistance;
  final String totalDuration;
  final String elevationGain;

  void _popToRoot(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) => const NavigationScaffold(initialIndex: 1),
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: <Widget>[
              const Spacer(flex: 2),

              Column(
                children: <Widget>[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colors.primaryNormal,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 48,
                      color: colors.staticWhite,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '경로 생성이 완료되었습니다',
                    style: AppTextStyles.headline2.bold.copyWith(
                      color: colors.labelNormal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '새로운 라이딩 경로를 즐겨보세요',
                    style: AppTextStyles.body2.normalRegular.copyWith(
                      color: colors.labelAssistive,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const Spacer(flex: 1),

              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text(
                        routeTitle,
                        style: AppTextStyles.heading2.bold.copyWith(
                          color: colors.labelNormal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    RouteStatsRow(
                      totalDistance: totalDistance,
                      totalDuration: totalDuration,
                      elevationGain: elevationGain,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: ButtonSolid(
                  text: '확인',
                  size: ButtonSize.large,
                  backgroundColor: colors.primaryNormal,
                  textColor: colors.staticWhite,
                  onPressed: () => _popToRoot(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
