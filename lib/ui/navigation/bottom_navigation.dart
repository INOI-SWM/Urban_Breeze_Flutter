import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart'; // For context.semanticColor
import 'package:ridingmate/core/theme/semantic_colors.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    // Get semantic colors from the context
    final SemanticColors semanticColors = context.semanticColor;

    return Container(
      decoration: BoxDecoration(
        color: semanticColors.backgroundNormalNormal,
        border: Border(
          top: BorderSide(
            color: semanticColors.lineNormalNormal.withOpacity(0.16),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        // To handle iOS safe area
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: Colors.transparent,
          elevation: 0, // No shadow
          indicatorColor: Colors.transparent,
          destinations: <Widget>[
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color:
                    currentIndex == 0
                        ? semanticColors.primaryNormal
                        : semanticColors.interactionInactive,
              ),
              selectedIcon: Icon(
                Icons.home,
                color:
                    currentIndex == 0
                        ? semanticColors.primaryNormal
                        : semanticColors.interactionInactive,
              ),
              label: '홈',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.route_outlined,
                color:
                    currentIndex == 1
                        ? semanticColors.primaryNormal
                        : semanticColors.interactionInactive,
              ),
              selectedIcon: Icon(
                Icons.route,
                color:
                    currentIndex == 1
                        ? semanticColors.primaryNormal
                        : semanticColors.interactionInactive,
              ),
              label: '경로 생성',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.directions_bike_outlined,
                color:
                    currentIndex == 2
                        ? semanticColors.primaryNormal
                        : semanticColors.interactionInactive,
              ),
              selectedIcon: Icon(
                Icons.directions_bike,
                color:
                    currentIndex == 2
                        ? semanticColors.primaryNormal
                        : semanticColors.interactionInactive,
              ),
              label: '라이딩',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.bar_chart_outlined,
                color:
                    currentIndex == 3
                        ? semanticColors.primaryNormal
                        : semanticColors.interactionInactive,
              ),
              selectedIcon: Icon(
                Icons.bar_chart,
                color:
                    currentIndex == 3
                        ? semanticColors.primaryNormal
                        : semanticColors.interactionInactive,
              ),
              label: '운동 기록',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline,
                color:
                    currentIndex == 4
                        ? semanticColors.primaryNormal
                        : semanticColors.interactionInactive,
              ),
              selectedIcon: Icon(
                Icons.person,
                color:
                    currentIndex == 4
                        ? semanticColors.primaryNormal
                        : semanticColors.interactionInactive,
              ),
              label: 'MY',
            ),
          ],
        ),
      ),
    );
  }
}
