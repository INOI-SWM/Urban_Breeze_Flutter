import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart'; // For context.semanticColor
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart'; // For AppTextStyles

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
          'icon': Icons.home_outlined,
          'selectedIcon': Icons.home,
          'label': '홈',
        },
        <String, dynamic>{
          'icon': Icons.route_outlined,
          'selectedIcon': Icons.route,
          'label': '경로 생성',
        },
        <String, dynamic>{
          'icon': Icons.directions_bike_outlined,
          'selectedIcon': Icons.directions_bike,
          'label': '라이딩',
        },
        <String, dynamic>{
          'icon': Icons.bar_chart_outlined,
          'selectedIcon': Icons.bar_chart,
          'label': '운동 기록',
        },
        <String, dynamic>{
          'icon': Icons.person_outline,
          'selectedIcon': Icons.person,
          'label': 'MY',
        },
      ];

  @override
  Widget build(BuildContext context) {
    final SemanticColors semanticColors = context.semanticColor;

    final TextStyle labelBaseStyle = AppTextStyles.caption2.medium;

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
        child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              labelTextStyle: WidgetStateProperty.resolveWith((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return labelBaseStyle.copyWith(
                    color: semanticColors.primaryNormal,
                  );
                }
                return labelBaseStyle.copyWith(
                  color: semanticColors.interactionInactive,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(
                    color: semanticColors.primaryNormal,
                    size: 24.0,
                  );
                }
                return IconThemeData(
                  color: semanticColors.interactionInactive,
                  size: 24.0,
                );
              }),
            ),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: Colors.transparent,
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
      ),
    );
  }
}
