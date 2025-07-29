import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
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
        const SizedBox(height: 20),

        // 임시 컨텐츠 (다음 단계에서 구현)
        Text(
          '선택된 탭: ${_currentData.selectedTab}',
          style: AppTextStyles.body1.normalMedium.copyWith(
            color: colors.labelNormal,
          ),
        ),
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
}
