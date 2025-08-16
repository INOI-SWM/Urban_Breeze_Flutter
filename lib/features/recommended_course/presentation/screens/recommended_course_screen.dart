import 'package:flutter/material.dart';
import 'package:ridingmate/features/recommended_course/application/services/recommended_course_service.dart';
import 'package:ridingmate/features/recommended_course/domain/enums/course_sort_type.dart';
import 'package:ridingmate/features/recommended_course/presentation/config/recommended_course_category_config.dart';
import 'package:ridingmate/features/recommended_course/presentation/config/recommended_course_filter_config.dart';
import 'package:ridingmate/features/recommended_course/presentation/screens/recommended_course_detail_screen.dart';
import 'package:ridingmate/navigation/page_with_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/card/route_card.dart';
import 'package:ridingmate/shared/design_system/widgets/category/category_filter.dart';
import 'package:ridingmate/shared/filter/filter_modal.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';
import 'package:ridingmate/shared/filter/models/filter_item.dart';
import 'package:ridingmate/shared/filter/utils/filter_display_utils.dart';
import 'package:ridingmate/shared/sort/sort_modal.dart';

class RecommendedCourseScreen extends StatefulWidget implements PageWithAppBar {
  const RecommendedCourseScreen({super.key});

  @override
  State<RecommendedCourseScreen> createState() =>
      _RecommendedCourseScreenState();

  @override
  PreferredSizeWidget getAppBar(BuildContext context) {
    return const CustomAppBar(
      title: '추천 코스',
      // 추천 코스는 사용자가 생성하는 것이 아니므로 추가 버튼 제거
    );
  }
}

class _RecommendedCourseScreenState extends State<RecommendedCourseScreen> {
  // TODO: 추천 코스용 정렬 옵션으로 변경 필요 (가까운순, 거리, 난이도)
  CourseSortType selectedSortOption = CourseSortType.newest;

  // 필터 생성
  List<FilterItem> get filters => RecommendedCourseFilterConfig().filters;

  late FilterData currentFilter;

  List<Map<String, dynamic>> courseList = <Map<String, dynamic>>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentFilter = FilterData.fromFilterItems(filters);
    _loadCourseList();
  }

  Future<void> _loadCourseList() async {
    setState(() {
      isLoading = true;
    });

    final List<Map<String, dynamic>> courses =
        await RecommendedCourseService.fetchRecommendedCourseList();
    setState(() {
      courseList = courses;
      isLoading = false;
    });
  }

  void _showSortModal() {
    SortModal.show<CourseSortType>(
      context: context,
      options: CourseSortType.values,
      selectedOption: selectedSortOption,
      onOptionSelected: (CourseSortType option) {
        setState(() {
          selectedSortOption = option;
        });
        // TODO: 정렬 로직 구현 (거리, 난이도 기준)
      },
      getDisplayText: (CourseSortType option) => option.displayName,
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
        // TODO: 필터 적용 로직 구현
      },
      onReset: () {
        setState(() {
          currentFilter = FilterData.fromFilterItems(filters);
        });
        // TODO: 초기화 후 데이터 새로고침
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
            categories: RecommendedCourseCategoryConfig.buildCategoryInfos(
              currentFilter,
              filters,
              selectedSortOption.displayName,
            ),
            selectedCategories: FilterDisplayUtils.getSelectedCategories(
              currentFilter,
              filters,
              selectedSortOption != CourseSortType.newest
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
                    : courseList.isEmpty
                    ? const Center(child: Text('추천 코스가 없습니다'))
                    : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: courseList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> course = courseList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RouteCard(
                            thumbnailPath: course['thumbnailPath'],
                            sourceType: course['sourceType'],
                            routeTitle: course['title'],
                            distance: course['distance'],
                            elevation: course['elevation'],
                            cardType: RouteCardType.recommendedCourse,
                            region: course['region'],
                            difficulty: course['difficulty'],
                            scenery: course['scenery'],
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder:
                                      (BuildContext context) =>
                                          const RecommendedCourseDetailScreen(),
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
