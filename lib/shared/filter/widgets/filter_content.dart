import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';
import 'package:ridingmate/shared/filter/models/filter_item.dart';
import 'package:ridingmate/shared/filter/widgets/filter_action_buttons.dart';
import 'package:ridingmate/shared/filter/widgets/filter_tab_bar.dart';
import 'package:ridingmate/shared/filter/widgets/filter_widgets.dart';

class FilterContent extends StatefulWidget {
  const FilterContent({
    super.key,
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
  State<FilterContent> createState() => _FilterContentState();
}

class _FilterContentState extends State<FilterContent> {
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
          FilterTabBar(
            filters: widget.filters,
            selectedTab: _currentData.selectedTab,
            scrollController: _tabScrollController,
            onTabChanged: _onTabChanged,
          ),

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
                        FilterWidgets.buildFilterWidget(
                          filter: filter,
                          currentData: _currentData,
                          onDataChanged: (FilterData newData) {
                            setState(() {
                              _currentData = newData;
                            });
                          },
                        ),
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
          FilterActionButtons(
            onReset: () {
              setState(() {
                _currentData = FilterData.fromFilterItems(widget.filters);
              });
              widget.onReset();
            },
            onApply: () {
              Navigator.of(context).pop();
              widget.onApply(_currentData);
            },
          ),
        ],
      ),
    );
  }
}
