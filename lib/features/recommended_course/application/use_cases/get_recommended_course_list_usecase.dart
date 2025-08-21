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

        if (courseList.courses.isEmpty) {
          // API 응답이 비어있는 경우 더미 데이터 반환
          return AppSuccess<List<RecommendedCourse>>(_getDummyData());
        }

        return AppSuccess<List<RecommendedCourse>>(courseList.courses);
      } catch (repositoryError) {
        // API 호출 실패시 테스트용 더미 데이터 반환
        await Future<void>.delayed(const Duration(milliseconds: 500));
        return AppSuccess<List<RecommendedCourse>>(_getDummyData());
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

  /// 테스트용 더미 데이터 생성
  List<RecommendedCourse> _getDummyData() {
    return <RecommendedCourse>[
      const RecommendedCourse(
        id: '1',
        title: '한강 라이딩 코스',
        description: '한강을 따라가는 아름다운 라이딩 코스입니다. 도시의 스카이라인을 감상하며 라이딩할 수 있습니다.',
        distanceKm: 25.0,
        durationSeconds: 0,
        elevationGain: 150.5,
        region: '서울특별시',
        difficulty: '쉬움',
        recommendationType: '유명 코스',
        thumbnailImagePath:
            'https://urban_breeze-dev.s3.ap-northeast-2.amazonaws.com/thumbnails/hangang.jpg',
      ),
      const RecommendedCourse(
        id: '2',
        title: '남산 순환 코스',
        description: '남산을 둘러보는 도심 속 힐링 라이딩 코스입니다.',
        distanceKm: 8.5,
        durationSeconds: 0,
        elevationGain: 200.0,
        region: '서울특별시',
        difficulty: '보통',
        recommendationType: '유명 코스',
        thumbnailImagePath:
            'https://urban_breeze-dev.s3.ap-northeast-2.amazonaws.com/thumbnails/namsan.jpg',
      ),
      const RecommendedCourse(
        id: '3',
        title: '강릉 해안도로',
        description: '동해안을 따라가는 해안 도로 코스입니다. 바다 전망을 감상하며 라이딩할 수 있습니다.',
        distanceKm: 60.0,
        durationSeconds: 0,
        elevationGain: 450.3,
        region: '강원',
        difficulty: '보통',
        recommendationType: '대회 코스',
        thumbnailImagePath:
            'https://urban_breeze-dev.s3.ap-northeast-2.amazonaws.com/thumbnails/gangneung.jpg',
      ),
      const RecommendedCourse(
        id: '4',
        title: '제주 올레길 코스',
        description: '제주의 아름다운 자연을 만끽할 수 있는 라이딩 코스입니다.',
        distanceKm: 35.2,
        durationSeconds: 0,
        elevationGain: 320.8,
        region: '제주',
        difficulty: '어려움',
        recommendationType: '국토 종주',
        thumbnailImagePath:
            'https://urban_breeze-dev.s3.ap-northeast-2.amazonaws.com/thumbnails/jeju.jpg',
      ),
      const RecommendedCourse(
        id: '5',
        title: '충주호 라이딩',
        description: '충주호의 맑은 물과 산세를 감상하며 달리는 코스입니다.',
        distanceKm: 42.0,
        durationSeconds: 0,
        elevationGain: 280.5,
        region: '충청',
        difficulty: '보통',
        recommendationType: '대회 코스',
        thumbnailImagePath:
            'https://urban_breeze-dev.s3.ap-northeast-2.amazonaws.com/thumbnails/chungju.jpg',
      ),
    ];
  }
}
