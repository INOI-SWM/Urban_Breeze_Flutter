import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/recommended_course/domain/constants/recommended_course_constants.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_filter.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_list.dart';
import 'package:urban_breeze/features/recommended_course/domain/enums/course_sort_type.dart';
import 'package:urban_breeze/features/recommended_course/domain/repositories/recommended_course_repository.dart';
import 'package:urban_breeze/shared/filter/models/filter_data.dart';
import 'package:urban_breeze/shared/filter/utils/filter_converter.dart';

class GetRecommendedCourseListUseCase {
  const GetRecommendedCourseListUseCase({
    required RecommendedCourseRepository repository,
  }) : _repository = repository;

  final RecommendedCourseRepository _repository;

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

      // 필터를 도메인 필터로 변환
      final RecommendedCourseFilter filter = _convertToFilter(
        categoryFilter,
        sortType: actualSortType.apiValue,
        minDistance: minDistance,
        maxDistance: maxDistance,
        minElevation: minElevation,
        maxElevation: maxElevation,
        page: 0,
        size: RecommendedCourseConstants.defaultPageSize,
      );

      try {
        // Repository 호출
        final RecommendedCourseList courseList = await _repository
            .getRecommendedCourseList(filter);

        return AppSuccess<List<RecommendedCourse>>(courseList.courses);
      } on NetworkException catch (e) {
        return AppFailure<List<RecommendedCourse>>(e);
      } on ServerException catch (e) {
        return AppFailure<List<RecommendedCourse>>(e);
      } catch (e) {
        return AppFailure<List<RecommendedCourse>>(
          ServerException('추천 코스 목록을 불러올 수 없습니다: ${e.toString()}'),
        );
      }
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

  /// categoryFilter를 RecommendedCourseFilter로 변환
  RecommendedCourseFilter _convertToFilter(
    Set<String>? categoryFilter, {
    String? sortType,
    double? minDistance,
    double? maxDistance,
    double? minElevation,
    double? maxElevation,
    int page = 0,
    int size = RecommendedCourseConstants.defaultPageSize,
  }) {
    List<String>? regions;
    List<String>? difficulties;
    List<String>? recommendationTypes;

    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      final List<String> extractedRegions = FilterConverter.extractCategoryType(
        categoryFilter,
        RecommendedCourseConstants.regions.toList(),
      );
      if (extractedRegions.isNotEmpty) {
        regions = extractedRegions;
      }

      final List<String> extractedDifficulties =
          FilterConverter.extractCategoryType(
            categoryFilter,
            RecommendedCourseConstants.difficulties.toList(),
          );
      if (extractedDifficulties.isNotEmpty) {
        difficulties = extractedDifficulties;
      }

      final List<String> extractedRecommendationTypes =
          FilterConverter.extractCategoryType(
            categoryFilter,
            RecommendedCourseConstants.recommendationTypes.toList(),
          );
      if (extractedRecommendationTypes.isNotEmpty) {
        recommendationTypes = extractedRecommendationTypes;
      }
    }

    return RecommendedCourseFilter(
      page: page,
      size: size,
      sortType: sortType ?? RecommendedCourseConstants.defaultSortType,
      regions: regions,
      difficulty: difficulties,
      recommendationTypes: recommendationTypes,
      minDistance: minDistance ?? RecommendedCourseConstants.defaultMinDistance,
      maxDistance: maxDistance ?? RecommendedCourseConstants.defaultMaxDistance,
      minElevation:
          minElevation ?? RecommendedCourseConstants.defaultMinElevation,
      maxElevation:
          maxElevation ?? RecommendedCourseConstants.defaultMaxElevation,
    );
  }
}
