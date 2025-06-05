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

  static const double _navigationBarHeight = 51.0;
  static const double _iconSize = 24.0;
  static const double _labelFontSize = 11.0;
  static const FontWeight _labelFontWeight = FontWeight.w500;
  static const double _labelLetterSpacing = 0.3421;
  static const double _labelLineHeight = 14.003;
  static const double _borderWidth = 1.0;
  static const double _borderAlpha = 0.16;

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

    return Container(
      decoration: BoxDecoration(
        color: semanticColors.backgroundNormalNormal,
        border: Border(
          top: BorderSide(
            color: semanticColors.lineNormalNormal.withValues(
              alpha: _borderAlpha,
            ),
            width: _borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              height: _navigationBarHeight,
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    fontSize: _labelFontSize,
                    fontWeight: _labelFontWeight,
                    letterSpacing: _labelLetterSpacing,
                    height: _labelLineHeight / _labelFontSize,
                    color: semanticColors.primaryNormal,
                  );
                }
                return TextStyle(
                  fontSize: _labelFontSize,
                  fontWeight: _labelFontWeight,
                  letterSpacing: _labelLetterSpacing,
                  height: _labelLineHeight / _labelFontSize,
                  color: semanticColors.interactionInactive,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(
                    color: semanticColors.primaryNormal,
                    size: _iconSize,
                  );
                }
                return IconThemeData(
                  color: semanticColors.interactionInactive,
                  size: _iconSize,
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
