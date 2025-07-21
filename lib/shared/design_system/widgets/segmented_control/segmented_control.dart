import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';

class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
    required this.labelExtractor,
  }) : assert(tabs.length >= 2, 'SegmentedControl must have at least 2 tabs');

  final List<T> tabs;
  final T selectedTab;
  final void Function(T tab) onTabSelected;
  final String Function(T tab) labelExtractor;

  static const double _containerHeight = 40.0;
  static const double _containerBorderRadius = 10.0;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Container(
      height: _containerHeight,
      decoration: BoxDecoration(
        color: colors.fillNormal,
        borderRadius: BorderRadius.circular(_containerBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
            tabs.map((T tab) {
              final String tabText = labelExtractor(tab);
              final bool isSelected = tab == selectedTab;

              return Expanded(
                child: _SegmentItem<T>(
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

class _SegmentItem<T> extends StatelessWidget {
  const _SegmentItem({
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

  static const double _itemBorderRadius = 8.0;
  static const EdgeInsets _itemMargin = EdgeInsets.all(2.0);
  static const EdgeInsets _itemPadding = EdgeInsets.all(9.0);
  static const double _shadowBlurRadius = 4.0;
  static const int _shadowOpacityAlpha = 20; // 8% opacity
  static const Offset _shadowOffset = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        margin: _itemMargin,
        decoration: BoxDecoration(
          color:
              isSelected ? colors.backgroundElevatedNormal : Colors.transparent,
          borderRadius: BorderRadius.circular(_itemBorderRadius),
          boxShadow: isSelected ? _buildBoxShadow() : null,
        ),
        padding: _itemPadding,
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.body2.normalMedium.copyWith(
              color: isSelected ? colors.labelNormal : colors.labelAlternative,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  List<BoxShadow> _buildBoxShadow() {
    return <BoxShadow>[
      BoxShadow(
        color: Colors.black.withAlpha(_shadowOpacityAlpha),
        blurRadius: _shadowBlurRadius,
        offset: _shadowOffset,
      ),
    ];
  }
}
