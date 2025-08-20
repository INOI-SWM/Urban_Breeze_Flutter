import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';

class CustomTabBar<T> extends StatelessWidget {
  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
    required this.labelExtractor,
  }) : assert(tabs.length >= 2, 'CustomTabBar must have at least 2 tabs');

  final List<T> tabs;
  final T selectedTab;
  final void Function(T tab) onTabSelected;
  final String Function(T tab) labelExtractor;

  static const double _containerHeight = 40.0;
  static const double _bottomBorderWidth = 1.0;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Container(
      height: _containerHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.lineNormalAlternative,
            width: _bottomBorderWidth,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
            tabs.map((T tab) {
              final String tabText = labelExtractor(tab);
              final bool isSelected = tab == selectedTab;

              return Expanded(
                child: _TabItem<T>(
                  key: ValueKey<T>(tab),
                  text: tabText,
                  value: tab,
                  isSelected: isSelected,
                  onTap: onTabSelected,
                  colors: colors,
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _TabItem<T> extends StatelessWidget {
  const _TabItem({
    super.key,
    required this.text,
    required this.value,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final String text;
  final T value;
  final bool isSelected;
  final void Function(T value) onTap;
  final SemanticColors colors;

  static const double _selectedBorderWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isSelected ? _buildSelectedDecoration() : null,
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.body2.normalBold.copyWith(
              color: isSelected ? colors.labelStrong : colors.labelAssistive,
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildSelectedDecoration() {
    return BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: colors.labelNormal,
          width: _selectedBorderWidth,
        ),
      ),
    );
  }
}
