import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/my_route/di/my_route_providers.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_filter.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_list.dart';
import 'package:urban_breeze/features/my_route/domain/enums/my_route_sort_type.dart';
import 'package:urban_breeze/features/my_route/presentation/config/my_route_category_config.dart';
import 'package:urban_breeze/features/my_route/presentation/config/my_route_filter_config.dart';
import 'package:urban_breeze/features/my_route/presentation/mappers/my_route_filter_mapper.dart';
import 'package:urban_breeze/features/my_route/presentation/screens/my_route_detail_screen.dart';
import 'package:urban_breeze/features/route_planning/presentation/screens/route_planning_screen.dart';
import 'package:urban_breeze/navigation/page_with_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/card/route_card.dart';
import 'package:urban_breeze/shared/design_system/widgets/category/category_filter.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:urban_breeze/shared/design_system/widgets/thumbnail/thumbnail.dart';
import 'package:urban_breeze/shared/filter/filter_modal.dart';
import 'package:urban_breeze/shared/filter/models/filter_data.dart';
import 'package:urban_breeze/shared/filter/models/filter_item.dart';
import 'package:urban_breeze/shared/filter/utils/filter_display_utils.dart';
import 'package:urban_breeze/shared/sort/sort_modal.dart';

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
            AmplitudeAnalytics.logButtonClick('my_route_add_button');
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
  late ScrollController _scrollController;

  // 상태 관리 변수들
  List<MyRoute> allRoutes = <MyRoute>[];
  MyRouteList routeList = MyRouteList.empty();
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  FilterData? currentFilter;
  MyRouteFilter? _currentDomainFilter;

  List<FilterItem> get filters {
    return MyRouteFilterConfig(
      maxDistance: routeList.maxDistance.ceilToDouble(),
      minDistance: routeList.minDistance.floorToDouble(),
      maxElevationGain: routeList.maxElevationGain.ceilToDouble(),
      minElevationGain: routeList.minElevationGain.floorToDouble(),
    ).filters;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadRouteList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView('my_route_screen');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        routeList.hasNext) {
      _loadMoreRoutes();
    }
  }

  Future<void> _loadRouteList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      allRoutes.clear();
    });

    late AppResult<MyRouteList> result;
    late MyRouteFilter filterModel;

    if (currentFilter == null) {
      // 초기 로딩 - 기본 필터 사용
      filterModel = MyRouteFilter(sortType: selectedSortOption);
    } else {
      // 필터 적용 - Mapper 사용
      filterModel = MyRouteFilterMapper.fromFilterData(
        currentFilter!,
        selectedSortOption,
      );
    }

    result = await ref
        .read(getMyRouteListUseCaseProvider)
        .execute(filter: filterModel);

    setState(() {
      isLoading = false;
      if (result.isSuccess) {
        routeList = result.dataOrNull!;
        allRoutes = List<MyRoute>.from(routeList.routes);
        _currentDomainFilter = filterModel;

        // 초기 로딩 시만 UI 필터 설정
        currentFilter ??= FilterData.fromFilterItems(filters);
      } else {
        errorMessage = '데이터를 불러올 수 없습니다';
        routeList = MyRouteList.empty();
        allRoutes.clear();
      }
    });
  }

  Future<void> _loadMoreRoutes() async {
    if (_currentDomainFilter == null) return;

    setState(() {
      isLoadingMore = true;
    });

    final MyRouteFilter nextPageFilter = _currentDomainFilter!.copyWith(
      page: routeList.currentPage + 1,
    );

    final AppResult<MyRouteList> result = await ref
        .read(getMyRouteListUseCaseProvider)
        .execute(filter: nextPageFilter);

    setState(() {
      isLoadingMore = false;
      if (result.isSuccess) {
        final MyRouteList newRouteList = result.dataOrNull!;
        allRoutes.addAll(newRouteList.routes);

        routeList = MyRouteList(
          routes: allRoutes,
          currentPage: newRouteList.currentPage,
          totalPages: newRouteList.totalPages,
          totalElements: newRouteList.totalElements,
          size: newRouteList.size,
          hasNext: newRouteList.hasNext,
          hasPrevious: newRouteList.hasPrevious,
          maxDistance: newRouteList.maxDistance,
          maxElevationGain: newRouteList.maxElevationGain,
          minDistance: newRouteList.minDistance,
          minElevationGain: newRouteList.minElevationGain,
        );
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

        AmplitudeAnalytics.logEvent(
          'my_route_sort_changed',
          properties: <String, dynamic>{
            'sort_type': option.name,
            'sort_display_name': option.displayName,
          },
        );

        _loadRouteList();
      },
      getDisplayText: (MyRouteSortType option) => option.displayName,
    );
  }

  void _showFilterModal({String? selectedTab}) {
    final MyRouteFilterConfig filterConfig = MyRouteFilterConfig(
      maxDistance: routeList.maxDistance.ceilToDouble(),
      minDistance: routeList.minDistance.floorToDouble(),
      maxElevationGain: routeList.maxElevationGain.ceilToDouble(),
      minElevationGain: routeList.minElevationGain.floorToDouble(),
    );

    final List<FilterItem> bottomSheetFilters = filterConfig.filters;

    final FilterData initialData = filterConfig
        .createFilterDataWithCurrentValues(currentFilter);

    FilterModal.show(
      context: context,
      filters: bottomSheetFilters,
      initialData: initialData,
      onApply: (FilterData newFilter) {
        setState(() {
          currentFilter = newFilter;
        });

        AmplitudeAnalytics.logEvent(
          'my_route_filter_applied',
          properties: <String, dynamic>{
            'filter_count': FilterDisplayUtils.getAppliedFiltersCount(
              newFilter,
              bottomSheetFilters,
            ),
          },
        );

        _loadRouteList();
      },
      onReset: () {
        setState(() {
          currentFilter = FilterData.fromFilterItems(bottomSheetFilters);
        });
        AmplitudeAnalytics.logEvent('my_route_filter_reset');
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
              currentFilter ?? FilterData.fromFilterItems(filters),
              filters,
              selectedSortOption.displayName,
            ),
            selectedCategories: FilterDisplayUtils.getSelectedCategories(
              currentFilter ?? FilterData.fromFilterItems(filters),
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
              currentFilter ?? FilterData.fromFilterItems(filters),
              filters,
            ),
            onFilterTap: () {
              _showFilterModal();
            },
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: AppLoadingIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (allRoutes.isEmpty) {
      return const Center(child: Text('경로가 없습니다'));
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: allRoutes.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index >= allRoutes.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: AppLoadingIndicator()),
          );
        }

        final MyRoute route = allRoutes[index];
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
              AmplitudeAnalytics.logEvent(
                'my_route_clicked',
                properties: <String, dynamic>{
                  'route_id': route.routeId.toString(),
                },
              );

              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder:
                      (BuildContext context) => MyRouteDetailScreen(
                        routeId: route.routeId.toString(),
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
