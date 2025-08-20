import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/recommended_course/application/services/recommended_course_service.dart';
import 'package:urban_breeze/features/recommended_course/domain/constants/recommended_course_constants.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course.dart';
import 'package:urban_breeze/features/recommended_course/domain/enums/course_sort_type.dart';
import 'package:urban_breeze/shared/filter/models/filter_data.dart';
import 'package:urban_breeze/shared/filter/utils/filter_converter.dart';

class GetRecommendedCourseListUseCase {
  const GetRecommendedCourseListUseCase({
    required RecommendedCourseService service,
  }) : _service = service;

  final RecommendedCourseService _service;

  Future<AppResult<List<RecommendedCourse>>> execute({
    FilterData? filterData,
    CourseSortType? sortType,
  }) async {
    try {
      // 기본값 설정
      final CourseSortType actualSortType = sortType ?? CourseSortType.nearest;

      Set<String> categoryFilter = <String>{};
      double minDistance = RecommendedCourseConstants.defaultMinDistance;
      double maxDistance = RecommendedCourseConstants.defaultMaxDistance;
      double minElevation = RecommendedCourseConstants.defaultMinElevation;
      double maxElevation = RecommendedCourseConstants.defaultMaxElevation;

      // FilterData가 제공된 경우 값 추출
      if (filterData != null) {
        // 카테고리 값 추출
        categoryFilter = _extractSelectedCategories(filterData);

        // Range 값 추출
        final (
          double extractedMinDistance,
          double extractedMaxDistance,
        ) = FilterConverter.extractDistanceRange(
          filterData,
          defaultMin: RecommendedCourseConstants.defaultMinDistance,
          defaultMax: RecommendedCourseConstants.defaultMaxDistance,
        );
        minDistance = extractedMinDistance;
        maxDistance = extractedMaxDistance;

        final (
          double extractedMinElevation,
          double extractedMaxElevation,
        ) = FilterConverter.extractElevationRange(
          filterData,
          defaultMin: RecommendedCourseConstants.defaultMinElevation,
          defaultMax: RecommendedCourseConstants.defaultMaxElevation,
        );
        minElevation = extractedMinElevation;
        maxElevation = extractedMaxElevation;
      }

      // Service 호출
      final List<RecommendedCourse> courses = await _service
          .fetchRecommendedCourseList(
            categoryFilter: categoryFilter,
            sortType: actualSortType.apiValue,
            minDistance: minDistance,
            maxDistance: maxDistance,
            minElevation: minElevation,
            maxElevation: maxElevation,
            page: 0,
            size: RecommendedCourseConstants.defaultPageSize,
          );

      return AppSuccess<List<RecommendedCourse>>(courses);
    } catch (e) {
      return AppFailure<List<RecommendedCourse>>(
        NetworkException(e.toString()),
      );
    }
  }

  /// 필터 데이터에서 선택된 카테고리 값들을 추출
  Set<String> _extractSelectedCategories(FilterData filterData) {
    final Set<String> selectedCategories = <String>{};

    // 지역 추출
    final String? region = FilterConverter.extractStringValue(
      filterData,
      'region',
    );
    if (region != null) {
      selectedCategories.add(region);
    }

    // 난이도 추출
    final String? difficulty = FilterConverter.extractStringValue(
      filterData,
      'difficulty',
    );
    if (difficulty != null) {
      selectedCategories.add(difficulty);
    }

    // 추천 타입 추출
    final String? recommendationType = FilterConverter.extractStringValue(
      filterData,
      'recommendation_type',
    );
    if (recommendationType != null) {
      selectedCategories.add(recommendationType);
    }

    return selectedCategories;
  }
}
