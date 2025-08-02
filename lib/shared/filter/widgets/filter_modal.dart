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
  const FilterModal._();

  static Future<FilterData?> show({
    required BuildContext context,
    required List<FilterItem> filters,
    required FilterData initialData,
    required Function(FilterData) onApply,
    required VoidCallback onReset,
  }) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.9;

    return BottomSheetShow.show<FilterData>(
      context: context,
      title: '필터',
      content: _FilterContent(
        filters: filters,
        initialData: initialData,
        onApply: onApply,
        onReset: onReset,
      ),
      constraints: BoxConstraints(maxHeight: maxHeight),
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
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();
  final Map<String, GlobalKey> _filterKeys =
      <String, GlobalKey<State<StatefulWidget>>>{};

  @override
  void initState() {
    super.initState();
    _currentData = widget.initialData;
    // 각 필터 위젯의 위치 추적을 위한 key 생성
    for (final FilterItem filter in widget.filters) {
      _filterKeys[filter.title] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _scrollContentsToSelected() {
    final String selectedTab = _currentData.selectedTab;
    final GlobalKey? key = _filterKeys[selectedTab];

    if (key?.currentContext != null) {
      // 위젯 렌더링이 완료된 후 스크롤 실행
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          // 해당 위젯이 화면에 보이도록 스크롤
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.0, // 상단에 정렬
          );
        } catch (e) {
          // 스크롤이 실패한 경우 탭 바를 스크롤
          _scrollTabToSelected(selectedTab);
          _showScrollLimitFeedback();
        }
      });
    }
  }

  void _scrollTabToSelected(String selectedTab) {
    final int selectedIndex = widget.filters.indexWhere(
      (FilterItem f) => f.title == selectedTab,
    );
    if (selectedIndex != -1) {
      // 탭 바에서 해당 탭이 보이도록 스크롤
      final double tabWidth = 120; // 탭 너비 + 패딩
      final double targetOffset = selectedIndex * tabWidth;

      // 스크롤 가능한 범위 확인
      final double maxScrollExtent =
          _tabScrollController.position.maxScrollExtent;
      final double adjustedTargetOffset = targetOffset.clamp(
        0.0,
        maxScrollExtent,
      );

      // 현재 스크롤 위치와 목표 위치가 다를 때만 스크롤
      if ((_tabScrollController.position.pixels - adjustedTargetOffset).abs() >
          10) {
        _tabScrollController.animateTo(
          adjustedTargetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // 탭 변경 시 스크롤 실행
  void _onTabChanged(String tabTitle) {
    setState(() {
      _currentData = _currentData.copyWith(selectedTab: tabTitle);
    });
    _scrollContentsToSelected();
    // 탭바도 항상 스크롤하여 선택된 탭이 보이도록 함
    _scrollTabToSelected(tabTitle);
  }

  void _showScrollLimitFeedback() {
    // 스크롤 한계에 도달했을 때 시각적 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_currentData.selectedTab} 필터가 선택되었습니다'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 탭 바
          _buildTabBar(colors),

          // 필터 컨텐츠
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ...widget.filters.asMap().entries.map((
                    MapEntry<int, FilterItem> entry,
                  ) {
                    final int index = entry.key;
                    final FilterItem filter = entry.value;
                    return Column(
                      key: _filterKeys[filter.title],
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildFilterWidget(filter, colors),
                        if (index < widget.filters.length - 1)
                          Container(
                            color: colors.backgroundNormalAlternative,
                            height: 8,
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          // 액션 버튼
          _buildActionButtons(colors),
        ],
      ),
    );
  }

  Widget _buildTabBar(SemanticColors colors) {
    return SingleChildScrollView(
      controller: _tabScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:
            widget.filters.asMap().entries.map((
              MapEntry<int, FilterItem> entry,
            ) {
              final int index = entry.key;
              final FilterItem filter = entry.value;
              final bool isSelected = filter.title == _currentData.selectedTab;

              return Padding(
                padding: EdgeInsets.only(
                  right: index < widget.filters.length - 1 ? 24 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    _onTabChanged(filter.title);
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
