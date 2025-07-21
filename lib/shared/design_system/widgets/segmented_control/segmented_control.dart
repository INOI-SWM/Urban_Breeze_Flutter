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

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    const double borderRadius = 10;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colors.fillNormal,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            tabs.map((T tab) {
              final String tabText = labelExtractor(tab);
              final bool isSelected = tab == selectedTab;

              return _SegmentItem<T>(
                key: ValueKey<T>(tab),
                text: tabText,
                value: tab,
                isSelected: isSelected,
                onTap: onTabSelected,
                colors: colors,
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

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 8; // 내부에서 직접 정의

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color:
              isSelected ? colors.backgroundElevatedNormal : Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow:
              isSelected
                  ? <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withAlpha(20), // 8% = 20/255
                      blurRadius: 4,
                      offset: const Offset(0, 0),
                    ),
                  ]
                  : null,
        ),
        child: GestureDetector(
          onTap: () => onTap(value),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Center(
              child: Text(
                text,
                style: AppTextStyles.body2.normalMedium.copyWith(
                  color:
                      isSelected ? colors.labelNormal : colors.labelAlternative,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
