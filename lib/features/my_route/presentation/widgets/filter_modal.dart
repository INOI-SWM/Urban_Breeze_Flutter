import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_outlined.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_size.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_solid.dart';
import 'package:ridingmate/shared/design_system/widgets/chip/chip_action.dart';
import 'package:ridingmate/shared/design_system/widgets/modal/bottom_sheet_modal.dart';

class FilterData {
  FilterData({
    this.selectedTab = '생성자',
    this.selectedCourseType = '전체',
    this.elevationRange = const RangeValues(0, 122),
    this.distanceRange = const RangeValues(0, 999),
  });

  String selectedTab;
  String selectedCourseType;
  RangeValues elevationRange;
  RangeValues distanceRange;

  FilterData copyWith({
    String? selectedTab,
    String? selectedCourseType,
    RangeValues? elevationRange,
    RangeValues? distanceRange,
  }) {
    return FilterData(
      selectedTab: selectedTab ?? this.selectedTab,
      selectedCourseType: selectedCourseType ?? this.selectedCourseType,
      elevationRange: elevationRange ?? this.elevationRange,
      distanceRange: distanceRange ?? this.distanceRange,
    );
  }
}

class FilterModal {
  static const List<String> tabs = <String>['생성자', '상승 고도', '거리'];
  static const List<String> courseTypes = <String>[
    '전체',
    '내가 생성한 경로',
    '공유 받은 경로',
  ];

  // 상승 고도 범위 (미터)
  static const double minElevation = 0;
  static const double maxElevation = 122;

  // 거리 범위 (킬로미터)
  static const double minDistance = 0;
  static const double maxDistance = 999;

  static Future<FilterData?> show({
    required BuildContext context,
    required FilterData initialData,
    required Function(FilterData) onApply,
    required VoidCallback onReset,
  }) {
    return BottomSheetShow.show<FilterData>(
      context: context,
      title: '필터',
      content: _FilterContent(
        initialData: initialData,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }
}

class _FilterContent extends StatefulWidget {
  const _FilterContent({
    required this.initialData,
    required this.onApply,
    required this.onReset,
  });

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
            // 생성자 필터
            _buildCourseTypeFilter(colors),
            Container(color: colors.backgroundNormalAlternative, height: 8),

            // 상승 고도 필터
            _buildElevationFilter(colors),
            Container(color: colors.backgroundNormalAlternative, height: 8),

            // 거리 필터
            _buildDistanceFilter(colors),
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
            FilterModal.tabs.map((String tab) {
              final bool isSelected = tab == _currentData.selectedTab;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentData = _currentData.copyWith(selectedTab: tab);
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
                    tab,
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

  Widget _buildCourseTypeFilter(SemanticColors colors) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '생성자',
            style: AppTextStyles.heading2.bold.copyWith(
              color: colors.labelStrong,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                FilterModal.courseTypes.map((String type) {
                  final bool isSelected =
                      type == _currentData.selectedCourseType;
                  return ChipAction(
                    text: type,
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
                        _currentData = _currentData.copyWith(
                          selectedCourseType: type,
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

  Widget _buildElevationFilter(SemanticColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '상승 고도',
            style: AppTextStyles.heading2.bold.copyWith(
              color: colors.labelStrong,
            ),
          ),
          const SizedBox(height: 16),
          _buildRangeSlider(
            colors: colors,
            values: _currentData.elevationRange,
            min: FilterModal.minElevation,
            max: FilterModal.maxElevation,
            unit: 'm',
            onChanged: (RangeValues values) {
              setState(() {
                _currentData = _currentData.copyWith(elevationRange: values);
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
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 100,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${values.start.round()} $unit',
                  style: AppTextStyles.label1.normalMedium.copyWith(
                    color: colors.labelNormal,
                  ),
                ),
                Text(
                  '${values.end.round()} $unit',
                  style: AppTextStyles.label1.normalMedium.copyWith(
                    color: colors.labelNormal,
                  ),
                ),
              ],
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
                  _currentData = FilterData(); // 기본값으로 초기화
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

  Widget _buildDistanceFilter(SemanticColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '거리',
            style: AppTextStyles.heading2.bold.copyWith(
              color: colors.labelStrong,
            ),
          ),
          const SizedBox(height: 16),
          _buildRangeSlider(
            colors: colors,
            values: _currentData.distanceRange,
            min: FilterModal.minDistance,
            max: FilterModal.maxDistance,
            unit: 'km',
            onChanged: (RangeValues values) {
              setState(() {
                _currentData = _currentData.copyWith(distanceRange: values);
              });
            },
          ),
        ],
      ),
    );
  }
}
