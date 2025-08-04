import 'package:flutter/material.dart';
import 'package:ridingmate/features/my_route/application/usecases/get_route_list_usecase.dart';
import 'package:ridingmate/features/my_route/application/utils/filter_converter.dart';
import 'package:ridingmate/features/my_route/data/datasources/route_remote_datasource.dart';
import 'package:ridingmate/features/my_route/data/models/route_filter_model.dart';
import 'package:ridingmate/features/my_route/data/models/route_model.dart';
import 'package:ridingmate/features/my_route/data/repositories/route_repository_impl.dart';
import 'package:ridingmate/features/my_route/domain/enums/route_sort_type.dart';
import 'package:ridingmate/features/my_route/presentation/config/my_route_category_config.dart';
import 'package:ridingmate/features/my_route/presentation/config/my_route_filter_config.dart';
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

class MyRouteScreen extends StatefulWidget implements PageWithAppBar {
  const MyRouteScreen({super.key});

  @override
  State<MyRouteScreen> createState() => _MyRouteScreenState();

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

class _MyRouteScreenState extends State<MyRouteScreen> {
  RouteSortType selectedSortOption = RouteSortType.newest;

  List<FilterItem> get filters => MyRouteFilterConfig().filters;

  late FilterData currentFilter;

  List<RouteModel> routeList = <RouteModel>[];
  bool isLoading = true;

  // UseCase 및 Repository 인스턴스
  late final GetRouteListUseCase _getRouteListUseCase;

  @override
  void initState() {
    super.initState();
    currentFilter = FilterData.fromFilterItems(filters);

    // UseCase 초기화
    final RouteRemoteDataSource dataSource = RouteRemoteDataSource();
    final RouteRepositoryImpl repository = RouteRepositoryImpl(
      remoteDataSource: dataSource,
    );
    _getRouteListUseCase = GetRouteListUseCase(repository: repository);

    _loadRouteList();
  }

  Future<void> _loadRouteList() async {
    setState(() {
      isLoading = true;
    });

    final RouteFilterModel filter = FilterConverter.convertFilterToApiFilter(
      currentFilter,
      selectedSortOption,
    );

    final List<RouteModel> routes = await _getRouteListUseCase.execute(
      filter: filter,
    );

    setState(() {
      routeList = routes;
      isLoading = false;
    });
  }

  void _showSortModal() {
    SortModal.show<RouteSortType>(
      context: context,
      options: RouteSortType.values,
      selectedOption: selectedSortOption,
      onOptionSelected: (RouteSortType option) {
        setState(() {
          selectedSortOption = option;
        });
        _loadRouteList();
      },
      getDisplayText: (RouteSortType option) => option.displayName,
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
              selectedSortOption != RouteSortType.newest
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
                    : routeList.isEmpty
                    ? const Center(child: Text('경로가 없습니다'))
                    : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: routeList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final RouteModel route = routeList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RouteCard(
                            thumbnailPath: route.thumbnailUrl,
                            sourceType: ThumbnailSourceType.network,
                            userProfileImage: route.profileImageUrl,
                            userName: route.nickname,
                            routeTitle: route.title,
                            date: route.createdAt.split('T')[0],
                            distance: '${route.distance}km',
                            elevation: '${route.elevationGain}m',
                            cardType: RouteCardType.myRoute,
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
