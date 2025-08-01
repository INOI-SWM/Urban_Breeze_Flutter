import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_outlined.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_size.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_solid.dart';
import 'package:ridingmate/shared/design_system/widgets/chip/chip_action.dart';
import 'package:ridingmate/shared/design_system/widgets/modal/bottom_sheet_modal.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';
import 'package:ridingmate/shared/filter/models/filter_item.dart';
import 'package:ridingmate/shared/filter/models/filter_type.dart';

class FilterModal {
  static const List<String> tabs = <String>['생성자', '상승 고도', '거리'];
  static const List<String> courseTypes = <String>[
    '전체',
    '내가 생성한 경로',
    '공유 받은 경로',
  ];

  static const double minElevation = 0;
  static const double maxElevation = 122;

  static const double minDistance = 0;
  static const double maxDistance = 999;

  static Future<FilterData?> show({
    required BuildContext context,
    required List<FilterItem> filters,
    required FilterData initialData,
    required Function(FilterData) onApply,
    required VoidCallback onReset,
  }) {
    return BottomSheetShow.show<FilterData>(
      context: context,
      title: '필터',
      content: _FilterContent(
        filters: filters,
        initialData: initialData,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }
}

class _FilterContent extends StatefulWidget {
  const _FilterContent({
    required this.filters,
    required this.initialData,
    required this.onApply,
    required this.onReset,
  });

  final List<FilterItem> filters;
  final FilterData initialData;
  final Function(FilterData) onApply;
  final VoidCallback onReset;

  @override
  State<_FilterContent> createState() => _FilterContentState();
}

class _FilterContentState extends State<_FilterContent> {
  late FilterData _currentData;

  @override
  void initState() {
    super.initState();
    _currentData = widget.initialData;
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Column(
      children: <Widget>[
        // 탭 바
        _buildTabBar(colors),

        // 필터 컨텐츠
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ...widget.filters.map((FilterItem filter) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildFilterWidget(filter, colors),
                  if (filter != widget.filters.last)
                    Container(
                      color: colors.backgroundNormalAlternative,
                      height: 8,
                    ),
                ],
              );
            }),
          ],
        ),

        // 액션 버튼
        _buildActionButtons(colors),
      ],
    );
  }

  Widget _buildTabBar(SemanticColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 24,
        children:
            widget.filters.map((FilterItem filter) {
              final bool isSelected = filter.title == _currentData.selectedTab;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentData = _currentData.copyWith(
                      selectedTab: filter.title,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            isSelected
                                ? colors.labelNormal
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    filter.title,
                    style: AppTextStyles.headline2.bold.copyWith(
                      color:
                          isSelected
                              ? colors.labelNormal
                              : colors.labelAssistive,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildFilterWidget(FilterItem filter, SemanticColors colors) {
    switch (filter.type) {
      case FilterType.selection:
        return _buildSelectionFilter(filter, colors);
      case FilterType.range:
        return _buildRangeFilter(filter, colors);
    }
  }

  Widget _buildSelectionFilter(FilterItem filter, SemanticColors colors) {
    final String? currentValue = _currentData.getStringValue(filter.id);
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
                      setState(() {
                        _currentData = _currentData.setStringValue(
                          filter.id,
                          option,
                        );
                      });
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeFilter(FilterItem filter, SemanticColors colors) {
    final RangeValues? currentValue = _currentData.getRangeValue(filter.id);
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
            colors: colors,
            values: currentValue ?? range,
            min: range.start,
            max: range.end,
            unit: unit,
            onChanged: (RangeValues values) {
              setState(() {
                _currentData = _currentData.setRangeValue(filter.id, values);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSlider({
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

  Widget _buildActionButtons(SemanticColors colors) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ButtonOutlined(
              text: '초기화',
              textColor: colors.labelNormal,
              borderColor: colors.lineNormalNeutral,
              size: ButtonSize.large,
              onPressed: () {
                setState(() {
                  _currentData = FilterData.fromFilterItems(widget.filters);
                });
                widget.onReset();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ButtonSolid(
              text: '적용하기',
              textColor: colors.staticWhite,
              backgroundColor: colors.primaryNormal,
              size: ButtonSize.large,
              onPressed: () {
                Navigator.of(context).pop();
                widget.onApply(_currentData);
              },
            ),
          ),
        ],
      ),
    );
  }
}
