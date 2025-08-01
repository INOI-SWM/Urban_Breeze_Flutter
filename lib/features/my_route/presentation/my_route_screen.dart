import 'package:flutter/material.dart';
import 'package:ridingmate/features/my_route/application/services/my_route_service.dart';
import 'package:ridingmate/features/my_route/presentation/my_route_filter_config.dart';
import 'package:ridingmate/navigation/page_with_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/card/route_card.dart';
import 'package:ridingmate/shared/design_system/widgets/category/category_filter.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';
import 'package:ridingmate/shared/filter/utils/filter_display_utils.dart';
import 'package:ridingmate/shared/filter/widgets/filter_modal.dart';
import 'package:ridingmate/shared/sort/widgets/sort_modal.dart';

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
  FilterData currentFilter = FilterData.fromFilterItems(
    MyRouteFilterConfig.filters,
  );

  List<Map<String, dynamic>> routeList = <Map<String, dynamic>>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRouteList();
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

  void _showFilterModal({String? selectedTab}) {
    final FilterData initialData =
        selectedTab != null
            ? currentFilter.copyWith(selectedTab: selectedTab)
            : currentFilter;

    FilterModal.show(
      context: context,
      filters: MyRouteFilterConfig.filters,
      initialData: initialData,
      onApply: (FilterData newFilter) {
        setState(() {
          currentFilter = newFilter;
        });
      },
      onReset: () {
        setState(() {
          currentFilter = FilterData.fromFilterItems(
            MyRouteFilterConfig.filters,
          );
        });
      },
      // TODO: 필터 적용 로직 구현
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
            categories: FilterDisplayUtils.getDisplayCategories(
              currentFilter,
              MyRouteFilterConfig.filters,
              selectedSortOption,
            ),
            selectedCategories: FilterDisplayUtils.getSelectedCategories(
              currentFilter,
              MyRouteFilterConfig.filters,
              selectedSortOption != SortModal.sortOptions.first
                  ? selectedSortOption
                  : null,
            ),
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
              FilterDisplayUtils.getCategoryText(
                    currentFilter,
                    MyRouteFilterConfig.filters,
                    '상승 고도',
                  ):
                  Icons.trending_up,
              FilterDisplayUtils.getCategoryText(
                    currentFilter,
                    MyRouteFilterConfig.filters,
                    '거리',
                  ):
                  Icons.route,
            },
            categoryRightIcons: <String, IconData>{
              selectedSortOption: Icons.expand_more,
            },
            showFilterIndicator: true,
            filterCount: FilterDisplayUtils.getAppliedFiltersCount(
              currentFilter,
              MyRouteFilterConfig.filters,
            ),
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
