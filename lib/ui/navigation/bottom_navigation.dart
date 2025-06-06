import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<Map<String, dynamic>> _navigationItems =
      <Map<String, dynamic>>[
        <String, dynamic>{
          'icon': Icons.home,
          'selectedIcon': Icons.home,
          'label': '홈',
        },
        <String, dynamic>{
          'icon': Icons.route,
          'selectedIcon': Icons.route,
          'label': '경로 생성',
        },
        <String, dynamic>{
          'icon': Icons.directions_bike,
          'selectedIcon': Icons.directions_bike,
          'label': '라이딩',
        },
        <String, dynamic>{
          'icon': Icons.bar_chart,
          'selectedIcon': Icons.bar_chart,
          'label': '운동 기록',
        },
        <String, dynamic>{
          'icon': Icons.person,
          'selectedIcon': Icons.person,
          'label': 'MY',
        },
      ];

  @override
  Widget build(BuildContext context) {
    final SemanticColors semanticColors = context.semanticColor;

    final double navigationBarHeight =
        defaultTargetPlatform == TargetPlatform.iOS ? 51.0 : 64.0;
    final double iconLabelVerticalGap =
        defaultTargetPlatform == TargetPlatform.iOS ? 3.0 : 6.0;

    return Container(
      decoration: BoxDecoration(
        color: semanticColors.backgroundNormalNormal,
        border: Border(
          top: BorderSide(
            color: semanticColors.lineNormalNeutral.withValues(alpha: 0.16),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: NavigationBar(
          height: navigationBarHeight,
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: Colors.transparent,
          labelPadding: EdgeInsets.only(top: iconLabelVerticalGap),
          destinations: <Widget>[
            for (final Map<String, dynamic> item in _navigationItems)
              NavigationDestination(
                icon: Icon(item['icon']),
                selectedIcon: Icon(item['selectedIcon']),
                label: item['label'],
              ),
          ],
        ),
      ),
    );
  }
}
