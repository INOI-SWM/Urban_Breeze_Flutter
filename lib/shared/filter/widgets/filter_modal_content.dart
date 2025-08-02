import 'package:flutter/material.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';
import 'package:ridingmate/shared/filter/models/filter_item.dart';
import 'package:ridingmate/shared/filter/widgets/filter_action_buttons.dart';
import 'package:ridingmate/shared/filter/widgets/filter_list.dart';
import 'package:ridingmate/shared/filter/widgets/filter_tab_bar.dart';

class FilterModalContent extends StatefulWidget {
  const FilterModalContent({
    super.key,
    required this.filters,
    required this.initialData,
    required this.onApply,
    required this.onReset,
    this.showTabBar = true,
  });

  final List<FilterItem> filters;
  final FilterData initialData;
  final Function(FilterData) onApply;
  final VoidCallback onReset;
  final bool showTabBar;

  @override
  State<FilterModalContent> createState() => _FilterModalContentState();
}

class _FilterModalContentState extends State<FilterModalContent> {
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

  void _scrollListToSelected() {
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
          _scrollTabBarToSelected(selectedTab);
        }
      });
    }
  }

  void _scrollTabBarToSelected(String selectedTab) {
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
    _scrollListToSelected();
    // 탭바도 항상 스크롤하여 선택된 탭이 보이도록 함
    _scrollTabBarToSelected(tabTitle);
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 탭 바 (조건부 표시)
          if (widget.showTabBar)
            FilterTabBar(
              filters: widget.filters,
              selectedTab: _currentData.selectedTab,
              scrollController: _tabScrollController,
              onTabChanged: _onTabChanged,
            ),

          // 필터 리스트
          Expanded(
            child: FilterList(
              filters: widget.filters,
              currentData: _currentData,
              filterKeys: _filterKeys,
              scrollController: _scrollController,
              onDataChanged: (FilterData newData) {
                setState(() {
                  _currentData = newData;
                });
              },
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
