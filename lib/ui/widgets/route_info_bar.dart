import 'package:flutter/material.dart';
import 'package:ridingmate/design_system/info/info_item.dart';
import 'package:ridingmate/design_system/navigation/top_navigation_bar.dart';

class RouteInfoBar extends StatelessWidget {
  const RouteInfoBar({
    super.key,
    required this.totalDistance,
    required this.totalDuration,
    required this.elevationGain,
  });

  final String totalDistance;
  final String totalDuration;
  final String elevationGain;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const TopNavigationBar(
            title: '경로 생성',
            centerTitle: false,
            titleTextSize: NavBarTitleSize.large,
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
