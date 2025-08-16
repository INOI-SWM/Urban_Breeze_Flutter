import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/core/result/app_result.dart';
import 'package:ridingmate/features/my_route/di/my_route_providers.dart';
import 'package:ridingmate/features/my_route/domain/entities/my_route.dart';
import 'package:ridingmate/features/my_route/domain/entities/my_route_list.dart';
import 'package:ridingmate/features/my_route/domain/enums/my_route_sort_type.dart';
import 'package:ridingmate/features/my_route/presentation/config/my_route_category_config.dart';
import 'package:ridingmate/features/my_route/presentation/config/my_route_filter_config.dart';
import 'package:ridingmate/features/my_route/presentation/screens/my_route_detail_screen.dart';
import 'package:ridingmate/features/route_planning/presentation/screens/route_planning_screen.dart';
import 'package:ridingmate/navigation/page_with_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/card/route_card.dart';
import 'package:ridingmate/shared/design_system/widgets/category/category_filter.dart';
import 'package:ridingmate/shared/design_system/widgets/thumbnail/thumbnail.dart';
import 'package:ridingmate/shared/filter/filter_modal.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';
import 'package:ridingmate/shared/filter/models/filter_item.dart';
import 'package:ridingmate/shared/filter/utils/filter_display_utils.dart';
import 'package:ridingmate/shared/sort/sort_modal.dart';

class MyRouteScreen extends ConsumerStatefulWidget implements PageWithAppBar {
  const MyRouteScreen({super.key});

  @override
  ConsumerState<MyRouteScreen> createState() => _MyRouteScreenState();

  @override
  PreferredSizeWidget getAppBar(BuildContext context) {
    return CustomAppBar(
      title: '나의 경로',
      actions: <Widget>[
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<RoutePlanningScreen>(
                builder: (BuildContext context) => const RoutePlanningScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _MyRouteScreenState extends ConsumerState<MyRouteScreen> {
  MyRouteSortType selectedSortOption = MyRouteSortType.newest;

  List<FilterItem> get filters => MyRouteFilterConfig().filters;

  late FilterData currentFilter;

  MyRouteList routeList = MyRouteList.empty();
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    currentFilter = FilterData.fromFilterItems(filters);
    _loadRouteList();
  }

  Future<void> _loadRouteList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final AppResult<MyRouteList> result = await ref
        .read(getMyRouteListUseCaseProvider)
        .execute(filterData: currentFilter, sortType: selectedSortOption);

    setState(() {
      isLoading = false;
      if (result.isSuccess) {
        routeList = result.dataOrNull!;
      } else {
        errorMessage = result.exceptionOrNull?.message ?? '알 수 없는 오류가 발생했습니다';
        routeList = MyRouteList.empty();
      }
    });
  }

  void _showSortModal() {
    SortModal.show<MyRouteSortType>(
      context: context,
      options: MyRouteSortType.values,
      selectedOption: selectedSortOption,
      onOptionSelected: (MyRouteSortType option) {
        setState(() {
          selectedSortOption = option;
        });
        _loadRouteList();
      },
      getDisplayText: (MyRouteSortType option) => option.displayName,
    );
  }

  void _showFilterModal({String? selectedTab}) {
    final FilterData initialData =
        selectedTab != null
            ? currentFilter.copyWith(selectedTab: selectedTab)
            : currentFilter;

    FilterModal.show(
      context: context,
      filters: filters,
      initialData: initialData,
      onApply: (FilterData newFilter) {
        setState(() {
          currentFilter = newFilter;
        });
        _loadRouteList();
      },
      onReset: () {
        setState(() {
          currentFilter = FilterData.fromFilterItems(filters);
        });
        _loadRouteList();
      },
      showTabBar: false,
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
            categories: MyRouteCategoryConfig.buildCategoryInfos(
              currentFilter,
              filters,
              selectedSortOption.displayName,
            ),
            selectedCategories: FilterDisplayUtils.getSelectedCategories(
              currentFilter,
              filters,
              selectedSortOption != MyRouteSortType.newest
                  ? selectedSortOption.displayName
                  : null,
            ),
            onCategorySelected: (String categoryId) {
              if (categoryId == 'sort') {
                _showSortModal();
              } else {
                final FilterItem filter = filters.firstWhere(
                  (FilterItem f) => f.id == categoryId,
                );
                _showFilterModal(selectedTab: filter.title);
              }
            },
            size: CategoryFilterSize.small,
            mode: CategoryFilterMode.alternative,
            showFilterIndicator: true,
            filterCount: FilterDisplayUtils.getAppliedFiltersCount(
              currentFilter,
              filters,
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
                    : errorMessage != null
                    ? Center(child: Text('오류: $errorMessage'))
                    : routeList.routes.isEmpty
                    ? const Center(child: Text('경로가 없습니다'))
                    : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: routeList.routes.length,
                      itemBuilder: (BuildContext context, int index) {
                        final MyRoute route = routeList.routes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RouteCard(
                            thumbnailPath: route.thumbnailUrl,
                            sourceType: ThumbnailSourceType.network,
                            userProfileImage: route.profileImageUrl,
                            userName: route.nickname,
                            routeTitle: route.title,
                            date: route.createdAtDisplay,
                            distance: route.distanceDisplay,
                            elevation: route.elevationGainDisplay,
                            cardType: RouteCardType.myRoute,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder:
                                      (BuildContext context) =>
                                          MyRouteDetailScreen(
                                            routeId: route.id.toString(),
                                          ),
                                ),
                              );
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
