import 'package:flutter/material.dart';
import 'package:ridingmate/features/my_route/application/services/my_route_service.dart';
import 'package:ridingmate/features/my_route/presentation/my_route_filter_config.dart';
import 'package:ridingmate/features/my_route/presentation/widgets/filter_modal.dart';
import 'package:ridingmate/features/my_route/presentation/widgets/sort_modal.dart';
import 'package:ridingmate/navigation/page_with_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/card/route_card.dart';
import 'package:ridingmate/shared/design_system/widgets/category/category_filter.dart';

class MyRouteScreen extends StatefulWidget implements PageWithAppBar {
  const MyRouteScreen({super.key});

  @override
  State<MyRouteScreen> createState() => _MyRouteScreenState();

  @override
  PreferredSizeWidget getAppBar(BuildContext context) {
    return CustomAppBar(
      title: '나의 경로',
      actions: <Widget>[
        IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
      ],
    );
  }
}

class _MyRouteScreenState extends State<MyRouteScreen> {
  String selectedSortOption = SortModal.sortOptions.first;
  GenericFilterData currentFilter = GenericFilterData.fromFilterItems(
    MyRouteFilterConfig.filters,
  );

  List<Map<String, dynamic>> routeList = <Map<String, dynamic>>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRouteList();
  }

  void _showSortModal() {
    SortModal.show(
      context: context,
      selectedOption: selectedSortOption,
      onOptionSelected: (String option) {
        setState(() {
          selectedSortOption = option;
        });
        // TODO: 정렬 로직 구현
      },
    );
  }

  Future<void> _loadRouteList() async {
    setState(() {
      isLoading = true;
    });

    final List<Map<String, dynamic>> routes =
        await RouteListService.fetchRouteList();
    setState(() {
      routeList = routes;
      isLoading = false;
    });
  }

  Set<String> _getSelectedCategories() {
    final Set<String> selectedCategories = <String>{};

    if (selectedSortOption != SortModal.sortOptions.first) {
      selectedCategories.add(selectedSortOption);
    }

    // 필터 설정에 따라 선택된 카테고리 추가
    for (final FilterItem filter in MyRouteFilterConfig.filters) {
      switch (filter.type) {
        case FilterType.selection:
          final String? value = currentFilter.getStringValue(filter.id);
          if (value != null && value != filter.options?.first) {
            selectedCategories.add(_getCategoryText(filter.title));
          }
          break;
        case FilterType.range:
          final RangeValues? value = currentFilter.getRangeValue(filter.id);
          final RangeValues defaultRange =
              filter.range ?? const RangeValues(0, 100);
          if (value != null &&
              (value.start != defaultRange.start ||
                  value.end != defaultRange.end)) {
            selectedCategories.add(_getCategoryText(filter.title));
          }
          break;
      }
    }

    return selectedCategories;
  }

  String _getCategoryText(String category) {
    // 필터 설정에서 해당 카테고리 찾기
    final FilterItem? filter =
        MyRouteFilterConfig.filters
            .where((FilterItem f) => f.title == category)
            .firstOrNull;

    if (filter == null) return category;

    switch (filter.type) {
      case FilterType.selection:
        final String? value = currentFilter.getStringValue(filter.id);
        if (value == null || value == filter.options?.first) {
          return filter.title; // 기본값이면 제목 반환
        }
        return value; // 선택된 값 반환
      case FilterType.range:
        final RangeValues? value = currentFilter.getRangeValue(filter.id);
        final RangeValues defaultRange =
            filter.range ?? const RangeValues(0, 100);
        if (value == null ||
            (value.start == defaultRange.start &&
                value.end == defaultRange.end)) {
          return filter.title; // 기본값이면 제목 반환
        }
        return '${value.start.round()} ~ ${value.end.round()} ${filter.unit}'; // 범위 값 반환
    }
  }

  int _getAppliedFiltersCount() {
    int count = 0;

    // 필터 설정에 따라 적용된 필터 개수 계산
    for (final FilterItem filter in MyRouteFilterConfig.filters) {
      switch (filter.type) {
        case FilterType.selection:
          final String? value = currentFilter.getStringValue(filter.id);
          if (value != null && value != filter.options?.first) {
            count++;
          }
          break;
        case FilterType.range:
          final RangeValues? value = currentFilter.getRangeValue(filter.id);
          final RangeValues defaultRange =
              filter.range ?? const RangeValues(0, 100);
          if (value != null &&
              (value.start != defaultRange.start ||
                  value.end != defaultRange.end)) {
            count++;
          }
          break;
      }
    }

    return count;
  }

  void _showFilterModal({String? selectedTab}) {
    // 특정 탭이 지정된 경우 필터 데이터의 선택된 탭 업데이트
    final GenericFilterData initialData =
        selectedTab != null
            ? currentFilter.copyWith(selectedTab: selectedTab)
            : currentFilter;

    FilterModal.showGeneric(
      context: context,
      filters: MyRouteFilterConfig.filters,
      initialData: initialData,
      onApply: (GenericFilterData newFilter) {
        setState(() {
          currentFilter = newFilter;
        });
      },
      onReset: () {
        setState(() {
          currentFilter = GenericFilterData.fromFilterItems(
            MyRouteFilterConfig.filters,
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CategoryFilter(
            categories: <String>[
              selectedSortOption,
              _getCategoryText('생성자'),
              _getCategoryText('상승 고도'),
              _getCategoryText('거리'),
            ],
            selectedCategories: _getSelectedCategories(),
            onCategorySelected: (String category) {
              if (category == selectedSortOption) {
                _showSortModal();
              } else {
                _showFilterModal(selectedTab: category);
              }
            },
            size: CategoryFilterSize.small,
            mode: CategoryFilterMode.alternative,
            categoryIcons: <String, IconData>{
              _getCategoryText('상승 고도'): Icons.trending_up,
              _getCategoryText('거리'): Icons.route,
            },
            categoryRightIcons: <String, IconData>{
              selectedSortOption: Icons.expand_more,
            },
            showFilterIndicator: true,
            filterCount: _getAppliedFiltersCount(),
            onFilterTap: () {
              _showFilterModal();
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : routeList.isEmpty
                    ? const Center(child: Text('경로가 없습니다'))
                    : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: routeList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> route = routeList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RouteCard(
                            thumbnailPath: route['thumbnailPath'],
                            sourceType: route['sourceType'],
                            userProfileImage: route['userProfileImage'],
                            userName: route['userName'],
                            routeTitle: route['title'],
                            date: route['createDate'],
                            distance: route['distance'],
                            elevation: route['elevation'],
                            onTap: () {
                              // TODO: 경로 상세 화면으로 이동
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
