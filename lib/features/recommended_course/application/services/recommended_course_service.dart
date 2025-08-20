import 'package:urban_breeze/features/recommended_course/domain/constants/recommended_course_constants.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_filter.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_list.dart';
import 'package:urban_breeze/features/recommended_course/domain/repositories/recommended_course_repository.dart';
import 'package:urban_breeze/shared/filter/utils/filter_converter.dart';

class RecommendedCourseService {
  const RecommendedCourseService({
    required RecommendedCourseRepository repository,
  }) : _repository = repository;

  final RecommendedCourseRepository _repository;

  /// 추천 코스 목록 조회
  Future<List<RecommendedCourse>> fetchRecommendedCourseList({
    Set<String>? categoryFilter,
    String? sortType,
    double? userLat,
    double? userLon,
    double? minDistance,
    double? maxDistance,
    double? minElevation,
    double? maxElevation,
    int page = 0,
    int size = RecommendedCourseConstants.defaultPageSize,
  }) async {
    try {
      // 필터를 도메인 필터로 변환
      final RecommendedCourseFilter filter = _convertToFilter(
        categoryFilter,
        sortType: sortType,
        userLat: userLat,
        userLon: userLon,
        minDistance: minDistance,
        maxDistance: maxDistance,
        minElevation: minElevation,
        maxElevation: maxElevation,
        page: page,
        size: size,
      );

      // API 호출
      final RecommendedCourseList courseList = await _repository
          .getRecommendedCourseList(filter);
      if (courseList.courses.isEmpty) {
        return _getDummyData();
      }
      // 도메인 엔티티 직접 반환
      return courseList.courses;
    } catch (e) {
      // API 호출 실패시 테스트용 더미 데이터 반환
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return _getDummyData();
    }
  }

  /// categoryFilter를 RecommendedCourseFilter로 변환
  RecommendedCourseFilter _convertToFilter(
    Set<String>? categoryFilter, {
    String? sortType,
    double? userLat,
    double? userLon,
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
      userLat: userLat,
      userLon: userLon,
    );
  }

  /// 테스트용 더미 데이터 생성
  List<RecommendedCourse> _getDummyData() {
    // 더미 추천 코스 데이터들
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

  // 카테고리 분류 로직은 FilterConverter.extractCategoryType으로 통합됨
}
