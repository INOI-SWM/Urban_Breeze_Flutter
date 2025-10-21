import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/recommended_course/data/mappers/recommended_course_request_mapper.dart';
import 'package:urban_breeze/features/recommended_course/di/recommended_course_providers.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_filter.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_list.dart';
import 'package:urban_breeze/features/recommended_course/domain/enums/recommended_course_sort_type.dart';
import 'package:urban_breeze/features/recommended_course/presentation/config/recommended_course_category_config.dart';
import 'package:urban_breeze/features/recommended_course/presentation/config/recommended_course_filter_config.dart';
import 'package:urban_breeze/features/recommended_course/presentation/screens/recommended_course_detail_screen.dart';
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
  RecommendedCourseSortType selectedSortOption =
      RecommendedCourseSortType.nearest;

  // 필터는 서버 응답 후에 생성됨
  FilterData? currentFilter;

  List<RecommendedCourse> courseList = <RecommendedCourse>[];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  RecommendedCourseList courseListData = RecommendedCourseList.empty();

  // 페이지네이션을 위한 ScrollController
  final ScrollController _scrollController = ScrollController();

  // 서버에서 받은 범위로 동적으로 필터 생성
  List<FilterItem> get filters {
    if (courseListData.isEmpty) {
      return const RecommendedCourseFilterConfig().filters;
    }
    return RecommendedCourseFilterConfig(
      maxDistance: courseListData.maxDistance.ceilToDouble(),
      minDistance: courseListData.minDistance.floorToDouble(),
      maxElevationGain: courseListData.maxElevationGain.ceilToDouble(),
      minElevationGain: courseListData.minElevationGain.floorToDouble(),
    ).filters;
  }

  @override
  void initState() {
    super.initState();
    _loadCourseList();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView('recommended_course_screen');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 끝에서 200px 전에 다음 페이지 로드
      if (!isLoadingMore && courseListData.hasNext) {
        _loadMoreCourses();
      }
    }
  }

  Future<void> _loadCourseList({bool isInitialLoad = true}) async {
    setState(() {
      if (isInitialLoad) {
        isLoading = true;
        courseList.clear();
      }
      errorMessage = null;
    });

    late AppResult<RecommendedCourseList> result;
    late RecommendedCourseFilter filterModel;

    // 필터가 없으면(첫 로딩) 필터 없이 요청, 있으면 필터 적용
    if (currentFilter == null) {
      // 첫 로딩: 범위 필터 없이 기본 요청
      filterModel = RecommendedCourseFilter(
        sortType: selectedSortOption,
        page: 0, // 첫 페이지부터
      );
    } else {
      // 필터 적용 - Mapper 사용
      filterModel = RecommendedCourseRequestMapper.fromFilterData(
        currentFilter!,
        selectedSortOption,
      );
    }

    result = await ref
        .read(getRecommendedCourseListUseCaseProvider)
        .execute(filter: filterModel);

    setState(() {
      isLoading = false;
      if (result.isSuccess) {
        courseListData = result.dataOrNull!;
        courseList = courseListData.courses;

        // 필터가 없었으면(첫 로딩) 서버에서 받은 실제 범위로 필터 생성
        if (currentFilter == null) {
          final RecommendedCourseFilterConfig
          filterConfig = RecommendedCourseFilterConfig(
            maxDistance: courseListData.maxDistance.ceilToDouble(),
            minDistance: courseListData.minDistance.floorToDouble(),
            maxElevationGain: courseListData.maxElevationGain.ceilToDouble(),
            minElevationGain: courseListData.minElevationGain.floorToDouble(),
          );
          currentFilter = FilterData.fromFilterItems(filterConfig.filters);
        }
      } else {
        errorMessage = '데이터를 불러올 수 없습니다';
        courseListData = RecommendedCourseList.empty();
        courseList.clear();
      }
    });
  }

  Future<void> _loadMoreCourses() async {
    if (isLoadingMore || !courseListData.hasNext) return;

    setState(() {
      isLoadingMore = true;
    });

    late RecommendedCourseFilter filterModel;

    // 현재 필터에 다음 페이지 번호 추가
    if (currentFilter == null) {
      filterModel = RecommendedCourseFilter(
        sortType: selectedSortOption,
        page: courseListData.currentPage + 1,
      );
    } else {
      filterModel = RecommendedCourseRequestMapper.fromFilterData(
        currentFilter!,
        selectedSortOption,
      ).copyWith(page: courseListData.currentPage + 1);
    }

    final AppResult<RecommendedCourseList> result = await ref
        .read(getRecommendedCourseListUseCaseProvider)
        .execute(filter: filterModel);

    setState(() {
      isLoadingMore = false;
      if (result.isSuccess) {
        final RecommendedCourseList newData = result.dataOrNull!;
        courseListData = RecommendedCourseList(
          courses: <RecommendedCourse>[...courseList, ...newData.courses],
          currentPage: newData.currentPage,
          totalPages: newData.totalPages,
          totalElements: newData.totalElements,
          size: newData.size,
          hasNext: newData.hasNext,
          hasPrevious: newData.hasPrevious,
          maxDistance: newData.maxDistance,
          maxElevationGain: newData.maxElevationGain,
          minDistance: newData.minDistance,
          minElevationGain: newData.minElevationGain,
        );
        courseList = courseListData.courses;
      }
    });
  }

  void _showSortModal() {
    SortModal.show<RecommendedCourseSortType>(
      context: context,
      options: RecommendedCourseSortType.values,
      selectedOption: selectedSortOption,
      onOptionSelected: (RecommendedCourseSortType option) {
        setState(() {
          selectedSortOption = option;
        });

        AmplitudeAnalytics.logEvent(
          'recommended_course_sort_changed',
          properties: <String, dynamic>{
            'sort_type': option.name,
            'sort_display_name': option.displayName,
          },
        );

        // 정렬 변경시 데이터 새로고침
        _loadCourseList();
      },
      getDisplayText: (RecommendedCourseSortType option) => option.displayName,
    );
  }

  void _showFilterModal({String? selectedTab}) {
    // 필터가 아직 준비되지 않았으면 리턴 (첫 로딩 중)
    if (currentFilter == null) return;

    final RecommendedCourseFilterConfig filterConfig =
        RecommendedCourseFilterConfig(
          maxDistance: courseListData.maxDistance.ceilToDouble(),
          minDistance: courseListData.minDistance.floorToDouble(),
          maxElevationGain: courseListData.maxElevationGain.ceilToDouble(),
          minElevationGain: courseListData.minElevationGain.floorToDouble(),
        );

    final List<FilterItem> bottomSheetFilters = filterConfig.filters;

    final FilterData initialData = filterConfig
        .createFilterDataWithCurrentValues(currentFilter!);

    FilterModal.show(
      context: context,
      filters: bottomSheetFilters,
      initialData: initialData,
      onApply: (FilterData newFilter) {
        setState(() {
          currentFilter = newFilter;
        });

        AmplitudeAnalytics.logEvent(
          'recommended_course_filter_applied',
          properties: <String, dynamic>{
            'filter_count': FilterDisplayUtils.getAppliedFiltersCount(
              newFilter,
              bottomSheetFilters,
            ),
          },
        );

        // 필터 적용시 데이터 새로고침
        _loadCourseList();
      },
      onReset: () {
        setState(() {
          currentFilter = FilterData.fromFilterItems(bottomSheetFilters);
        });

        AmplitudeAnalytics.logEvent('recommended_course_filter_reset');

        _loadCourseList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // currentFilter가 null이면 기본 빈 FilterData 사용
    final FilterData activeFilter =
        currentFilter ?? FilterData.fromFilterItems(filters);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CategoryFilter(
            categories: RecommendedCourseCategoryConfig.buildCategoryInfos(
              activeFilter,
              filters,
              selectedSortOption.displayName,
            ),
            selectedCategories: FilterDisplayUtils.getSelectedCategories(
              activeFilter,
              filters,
              selectedSortOption != RecommendedCourseSortType.nearest
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
              activeFilter,
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
                    ? const Center(child: AppLoadingIndicator())
                    : errorMessage != null
                    ? Center(child: Text('오류: $errorMessage'))
                    : courseList.isEmpty
                    ? const Center(child: Text('추천 코스가 없습니다'))
                    : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: courseList.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (BuildContext context, int index) {
                        // 로딩 인디케이터
                        if (index == courseList.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: AppLoadingIndicator()),
                          );
                        }

                        final RecommendedCourse course = courseList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RouteCard(
                            thumbnailPath: course.thumbnailImagePath,
                            sourceType: ThumbnailSourceType.network,
                            routeTitle: course.title,
                            distance: course.distanceDisplay,
                            elevation: course.elevationGainDisplay,
                            cardType: RouteCardType.recommendedCourse,
                            region: course.region,
                            difficulty: course.difficulty,
                            scenery: course.recommendationType,
                            onTap: () {
                              // 추천 코스 클릭 이벤트
                              AmplitudeAnalytics.logEvent(
                                'recommended_course_clicked',
                                properties: <String, dynamic>{
                                  'course_id': course.routeId,
                                },
                              );

                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder:
                                      (BuildContext context) =>
                                          RecommendedCourseDetailScreen(
                                            routeId: course.routeId,
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
