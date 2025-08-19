import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/chip/chip_action.dart';
import 'package:urban_breeze/shared/filter/models/filter_data.dart';
import 'package:urban_breeze/shared/filter/models/filter_item.dart';
import 'package:urban_breeze/shared/filter/models/filter_type.dart';

class FilterWidgets {
  const FilterWidgets._();

  static Widget buildFilterWidget({
    required FilterItem filter,
    required FilterData currentData,
    required Function(FilterData) onDataChanged,
  }) {
    return Builder(
      builder: (BuildContext context) {
        final SemanticColors colors = context.semanticColor;

        switch (filter.type) {
          case FilterType.selection:
            return _buildSelectionFilter(
              filter: filter,
              currentData: currentData,
              onDataChanged: onDataChanged,
              colors: colors,
            );
          case FilterType.range:
            return _buildRangeFilter(
              filter: filter,
              currentData: currentData,
              onDataChanged: onDataChanged,
              context: context,
              colors: colors,
            );
        }
      },
    );
  }

  static Widget _buildSelectionFilter({
    required FilterItem filter,
    required FilterData currentData,
    required Function(FilterData) onDataChanged,
    required SemanticColors colors,
  }) {
    final String? currentValue = currentData.getStringValue(filter.id);
    final List<String> options = filter.options ?? <String>[];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            filter.title,
            style: AppTextStyles.heading2.bold.copyWith(
              color: colors.labelStrong,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                options.map((String option) {
                  final bool isSelected = option == currentValue;
                  return ChipAction(
                    text: option,
                    size: ChipActionSize.small,
                    type: ChipActionType.outlined,
                    textColor:
                        isSelected
                            ? colors.primaryNormal
                            : colors.labelAlternative,
                    borderColor:
                        isSelected
                            ? colors.primaryNormal.withValues(alpha: 0.43)
                            : colors.lineNormalNeutral,
                    backgroundColor:
                        isSelected
                            ? colors.primaryNormal.withValues(alpha: 0.05)
                            : null,
                    onPressed: () {
                      onDataChanged(
                        currentData.setStringValue(filter.id, option),
                      );
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  static Widget _buildRangeFilter({
    required FilterItem filter,
    required FilterData currentData,
    required Function(FilterData) onDataChanged,
    required BuildContext context,
    required SemanticColors colors,
  }) {
    final RangeValues? currentValue = currentData.getRangeValue(filter.id);
    final RangeValues range = filter.range ?? const RangeValues(0, 100);
    final String unit = filter.unit ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            filter.title,
            style: AppTextStyles.heading2.bold.copyWith(
              color: colors.labelStrong,
            ),
          ),
          const SizedBox(height: 16),
          _buildRangeSlider(
            context: context,
            colors: colors,
            values: currentValue ?? range,
            min: range.start,
            max: range.end,
            unit: unit,
            onChanged: (RangeValues values) {
              onDataChanged(currentData.setRangeValue(filter.id, values));
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildRangeSlider({
    required BuildContext context,
    required SemanticColors colors,
    required RangeValues values,
    required double min,
    required double max,
    required String unit,
    required Function(RangeValues) onChanged,
  }) {
    return Column(
      children: <Widget>[
        // 범위 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${values.start.round()} $unit',
              style: AppTextStyles.headline2.bold.copyWith(
                color: colors.labelNormal,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '~',
              style: AppTextStyles.headline2.bold.copyWith(
                color: colors.labelNormal,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${values.end.round()} $unit',
              style: AppTextStyles.headline2.bold.copyWith(
                color: colors.labelNormal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 슬라이더
        Column(
          children: <Widget>[
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: colors.primaryNormal,
                inactiveTrackColor: colors.fillStrong,
                thumbColor: colors.primaryNormal,
                overlayColor: colors.primaryNormal.withValues(alpha: 0.2),
                rangeThumbShape: const RoundRangeSliderThumbShape(
                  enabledThumbRadius: 10,
                  elevation: 2,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              ),
              child: RangeSlider(
                values: values,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(height: 8),
            // 최소/최대값 표시
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${min.round()} $unit',
                    style: AppTextStyles.label1.normalMedium.copyWith(
                      color: colors.labelNormal,
                    ),
                  ),
                  Text(
                    '${max.round()} $unit',
                    style: AppTextStyles.label1.normalMedium.copyWith(
                      color: colors.labelNormal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
