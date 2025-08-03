import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';

class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<NavigationItem> _navigationItems = <NavigationItem>[
    NavigationItem(icon: Icons.home, selectedIcon: Icons.home, label: '홈'),
    NavigationItem(
      icon: Icons.route,
      selectedIcon: Icons.route,
      label: '추천 코스',
    ),
    NavigationItem(
      icon: Icons.directions_bike,
      selectedIcon: Icons.directions_bike,
      label: '나의 경로',
    ),
    NavigationItem(
      icon: Icons.bar_chart,
      selectedIcon: Icons.bar_chart,
      label: '기록',
    ),
    NavigationItem(icon: Icons.person, selectedIcon: Icons.person, label: 'MY'),
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
            for (final NavigationItem item in _navigationItems)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}
