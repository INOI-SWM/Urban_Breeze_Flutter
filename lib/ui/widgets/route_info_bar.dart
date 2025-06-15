import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/button/button_size.dart';
import 'package:ridingmate/design_system/button/button_solid.dart';
import 'package:ridingmate/design_system/info/info_item.dart';
import 'package:ridingmate/design_system/navigation/top_navigation_bar.dart';

class RouteInfoBar extends StatelessWidget {
  const RouteInfoBar({
    super.key,
    required this.totalDistance,
    required this.totalDuration,
    required this.elevationGain,
    required this.hasRoute,
    this.onSave,
  });

  final String totalDistance;
  final String totalDuration;
  final String elevationGain;
  final bool hasRoute;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Material(
      elevation: 8,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TopNavigationBar(
            title: '경로 생성',
            centerTitle: false,
            titleTextSize: NavBarTitleSize.large,
            actions: <Widget>[
              ButtonSolid(
                text: '저장',
                size: ButtonSize.small,
                backgroundColor:
                    hasRoute ? colors.primaryNormal : colors.interactionDisable,
                textColor:
                    hasRoute ? colors.staticWhite : colors.labelAssistive,
                onPressed: hasRoute ? onSave : null,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: InfoItem(label: '예상 소요시간', value: totalDuration),
                ),
                Expanded(
                  child: InfoItem(label: '총 거리', value: '$totalDistance km'),
                ),
                Expanded(
                  child: InfoItem(label: '총 상승고도', value: elevationGain),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
