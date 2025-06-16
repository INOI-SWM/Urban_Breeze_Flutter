import 'package:flutter/material.dart';
import 'package:ridingmate/core/design/typography/app_text_style.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/shared/widgets/button/icon_button_solid.dart';
import 'package:ridingmate/shared/widgets/icon/icon_size.dart';

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
    final TextStyle textStyle = AppTextStyles.caption2.medium;

    final int effectiveItemCount =
        settings.length > _gridColumns * _maxRows
            ? _gridColumns * _maxRows
            : settings.length;

    final double textHeightEstimate = textStyle.fontSize! * textStyle.height!;
    final double itemHeightEstimate =
        _buttonCustomSize +
        _iconTextSpacing +
        textHeightEstimate +
        (_itemVerticalPadding * 2);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double childAspectRatio = _calculateChildAspectRatio(
          constraints,
          itemHeightEstimate,
        );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: effectiveItemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _gridColumns,
            crossAxisSpacing: _gridGap,
            mainAxisSpacing: _gridGap,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (BuildContext context, int index) {
            final bool isSelected = selectedIndices.contains(index);
            final POISetting setting = settings[index];

            final Color textColor =
                isSelected ? colors.primaryNormal : colors.labelDisable;
            final TextStyle effectiveTextStyle = textStyle.copyWith(
              color: textColor,
            );

            return Padding(
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
                        isSelected ? colors.primaryNormal : colors.fillNormal,
                    iconColor:
                        isSelected ? colors.staticWhite : colors.labelDisable,
                    customButtonSize: _buttonCustomSize,
                  ),
                  const SizedBox(height: _iconTextSpacing),
                  Text(
                    setting.label,
                    textAlign: TextAlign.center,
                    style: effectiveTextStyle,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _calculateChildAspectRatio(
    BoxConstraints constraints,
    double itemHeight,
  ) {
    final double itemWidth =
        (constraints.maxWidth - (_gridGap * (_gridColumns - 1))) / _gridColumns;
    return itemWidth / itemHeight;
  }
}
