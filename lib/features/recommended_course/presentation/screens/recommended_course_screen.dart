import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/recommended_course/application/services/recommended_course_service.dart';
import 'package:ridingmate/features/recommended_course/di/recommended_course_providers.dart';
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

class RecommendedCourseScreen extends ConsumerStatefulWidget
    implements PageWithAppBar {
  const RecommendedCourseScreen({super.key});

  @override
  ConsumerState<RecommendedCourseScreen> createState() =>
      _RecommendedCourseScreenState();

  @override
  PreferredSizeWidget getAppBar(BuildContext context) {
    return const CustomAppBar(
      title: '추천 코스',
      // 추천 코스는 사용자가 생성하는 것이 아니므로 추가 버튼 제거
    );
  }
}

class _RecommendedCourseScreenState
    extends ConsumerState<RecommendedCourseScreen> {
  // 추천 코스용 정렬 옵션 (API 기본값: 가까운 순)
  CourseSortType selectedSortOption = CourseSortType.nearest;

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

    final RecommendedCourseService service = ref.read(
      recommendedCourseServiceProvider,
    );
    final List<Map<String, dynamic>> courses = await service
        .fetchRecommendedCourseList(
          sortType: selectedSortOption.apiValue,
          page: 0,
          size: 10, // API 기본값
        );
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
        // 정렬 변경시 데이터 새로고침
        _loadCourseList();
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
        // 필터 적용시 데이터 새로고침
        _loadCourseList();
      },
      onReset: () {
        setState(() {
          currentFilter = FilterData.fromFilterItems(filters);
        });
        // 초기화 후 데이터 새로고침
        _loadCourseList();
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
              selectedSortOption != CourseSortType.nearest
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
