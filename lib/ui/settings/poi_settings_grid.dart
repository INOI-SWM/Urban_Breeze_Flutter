import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/Icon/icon_size.dart';
import 'package:ridingmate/design_system/button/icon_button_solid.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

class POISetting {
  const POISetting({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class POISettingsGrid extends StatelessWidget {
  const POISettingsGrid({
    super.key,
    required this.settings,
    required this.selectedIndices,
    required this.onToggleSetting,
  });

  static const double _gridGap = 10.0;
  static const int _gridColumns = 4;
  static const double _itemVerticalPadding = 4.0;
  static const double _iconTextSpacing = 4.0;
  static const double _buttonCustomSize = 48.0;
  static const int _maxRows = 2;

  final List<POISetting> settings;
  final Set<int> selectedIndices;
  final void Function(int) onToggleSetting;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final int totalRows = (settings.length / _gridColumns).ceil();
    final int effectiveRows = totalRows > _maxRows ? _maxRows : totalRows;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double totalHorizontalSpacing = _gridGap * (_gridColumns - 1);
        final double itemWidth =
            (constraints.maxWidth - totalHorizontalSpacing) / _gridColumns;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(effectiveRows, (int rowIndex) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: rowIndex < effectiveRows - 1 ? _gridGap : 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List<Widget>.generate(_gridColumns, (int colIndex) {
                  final int index = rowIndex * _gridColumns + colIndex;
                  if (index >= settings.length) {
                    return SizedBox(width: itemWidth);
                  }

                  final bool isSelected = selectedIndices.contains(index);
                  final POISetting setting = settings[index];

                  return SizedBox(
                    width: itemWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: _itemVerticalPadding,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButtonSolid(
                            icon: setting.icon,
                            onPressed: () => onToggleSetting(index),
                            iconSize: IconSize.xlarge,
                            backgroundColor:
                                isSelected
                                    ? colors.primaryNormal
                                    : colors.fillNormal,
                            iconColor:
                                isSelected
                                    ? colors.staticWhite
                                    : colors.labelDisable,
                            customButtonSize: _buttonCustomSize,
                          ),
                          const SizedBox(height: _iconTextSpacing),
                          Text(
                            setting.label,
                            style: AppTextStyles.caption2.medium.copyWith(
                              color:
                                  isSelected
                                      ? colors.primaryNormal
                                      : colors.labelDisable,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }
}
