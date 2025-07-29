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
        // 임시 텍스트 (단계별로 대체될 예정)
        Text(
          'FilterModal 기본 구조',
          style: AppTextStyles.heading2.bold.copyWith(
            color: colors.labelNormal,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '탭: ${_currentData.selectedTab}',
          style: AppTextStyles.body1.normalMedium.copyWith(
            color: colors.labelNormal,
          ),
        ),
        Text(
          '코스 타입: ${_currentData.selectedCourseType}',
          style: AppTextStyles.body1.normalMedium.copyWith(
            color: colors.labelNormal,
          ),
        ),
      ],
    );
  }
}
