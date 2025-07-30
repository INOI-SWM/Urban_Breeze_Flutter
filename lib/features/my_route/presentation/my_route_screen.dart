import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/my_route/application/services/my_route_service.dart';
import 'package:ridingmate/features/my_route/presentation/widgets/filter_modal.dart';
import 'package:ridingmate/features/my_route/presentation/widgets/sort_modal.dart';
import 'package:ridingmate/navigation/page_with_app_bar.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:ridingmate/shared/design_system/widgets/card/route_card.dart';
import 'package:ridingmate/shared/design_system/widgets/category/category_filter.dart';

class MyRouteScreen extends StatefulWidget implements PageWithAppBar {
  const MyRouteScreen({super.key});

  @override
  State<MyRouteScreen> createState() => _MyRouteScreenState();

  @override
  PreferredSizeWidget getAppBar(BuildContext context) {
    return CustomAppBar(
      leading: CustomIconButton(icon: Icons.arrow_back_ios_new, onTap: () {}),
      title: '나의 경로',
      actions: <Widget>[
        IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
      ],
    );
  }
}

class _MyRouteScreenState extends State<MyRouteScreen> {
  String selectedSortOption = SortModal.sortOptions.first;
  FilterData currentFilter = FilterData();

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

    // 정렬이 기본값이 아닌 경우
    if (selectedSortOption != SortModal.sortOptions.first) {
      selectedCategories.add(selectedSortOption);
    }

    // 생성자 필터가 기본값이 아닌 경우
    if (currentFilter.selectedCourseType != '전체') {
      selectedCategories.add(_getCategoryText('생성자'));
    }

    // 상승 고도 필터가 기본값이 아닌 경우
    if (currentFilter.elevationRange.start != 0 ||
        currentFilter.elevationRange.end != 122) {
      selectedCategories.add(_getCategoryText('상승 고도'));
    }

    // 거리 필터가 기본값이 아닌 경우
    if (currentFilter.distanceRange.start != 0 ||
        currentFilter.distanceRange.end != 999) {
      selectedCategories.add(_getCategoryText('거리'));
    }

    return selectedCategories;
  }

  // 필터 카테고리 텍스트를 가져오는 메서드
  String _getCategoryText(String category) {
    switch (category) {
      case '생성자':
        return currentFilter.selectedCreatorValue;
      case '상승 고도':
        return currentFilter.selectedElevationValue;
      case '거리':
        return currentFilter.selectedDistanceValue;
      default:
        return category;
    }
  }

  void _showFilterModal({String? selectedTab}) {
    // 특정 탭이 지정된 경우 필터 데이터의 선택된 탭 업데이트
    final FilterData initialData =
        selectedTab != null
            ? currentFilter.copyWith(selectedTab: selectedTab)
            : currentFilter;

    FilterModal.show(
      context: context,
      initialData: initialData,
      onApply: (FilterData newFilter) {
        setState(() {
          currentFilter = newFilter;
        });
      },
      onReset: () {
        setState(() {
          currentFilter = FilterData();
        });
      },
      // TODO: 필터 로직 구현
    );
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 4,
            children: <Widget>[
              Expanded(
                child: CategoryFilter(
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
                ),
              ),
            ],
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
