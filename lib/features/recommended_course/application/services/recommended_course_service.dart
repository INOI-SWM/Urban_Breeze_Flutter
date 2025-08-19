import 'package:ridingmate/features/recommended_course/domain/constants/recommended_course_constants.dart';
import 'package:ridingmate/features/recommended_course/domain/entities/recommended_course.dart';
import 'package:ridingmate/features/recommended_course/domain/entities/recommended_course_filter.dart';
import 'package:ridingmate/features/recommended_course/domain/entities/recommended_course_list.dart';
import 'package:ridingmate/features/recommended_course/domain/repositories/recommended_course_repository.dart';
import 'package:ridingmate/shared/design_system/widgets/thumbnail/thumbnail.dart';

class RecommendedCourseService {
  const RecommendedCourseService({
    required RecommendedCourseRepository repository,
  }) : _repository = repository;

  final RecommendedCourseRepository _repository;

  /// 추천 코스 목록 조회
  Future<List<Map<String, dynamic>>> fetchRecommendedCourseList({
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

      // UI에서 사용하는 Map 형태로 변환
      return courseList.courses.map(_convertToMap).toList();
    } catch (e) {
      // 에러 발생시 빈 리스트 반환 (API 호출 실패)
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return <Map<String, dynamic>>[];
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
      final List<String> extractedRegions = _extractRegions(categoryFilter);
      if (extractedRegions.isNotEmpty) {
        regions = extractedRegions;
      }

      final List<String> extractedDifficulties = _extractDifficulties(
        categoryFilter,
      );
      if (extractedDifficulties.isNotEmpty) {
        difficulties = extractedDifficulties;
      }

      final List<String> extractedRecommendationTypes =
          _extractRecommendationTypes(categoryFilter);
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

  /// RecommendedCourse를 Map으로 변환 (기존 UI 호환성 위해)
  Map<String, dynamic> _convertToMap(RecommendedCourse course) {
    return <String, dynamic>{
      'id': course.id,
      'thumbnailPath': course.thumbnailImagePath,
      'sourceType': ThumbnailSourceType.network, // API에서 온 것은 network
      'badgeText': '추천', // 기본값
      'title': course.title,
      'distance': course.distanceDisplay,
      'elevation': course.elevationGainDisplay,
      'courseType': course.recommendationType,
      'region': course.region,
      'difficulty': course.difficulty,
    };
  }

  // === 카테고리 분류 헬퍼 메서드들 ===
  List<String> _extractRegions(Set<String> categories) {
    return categories
        .where(
          (String category) =>
              RecommendedCourseConstants.regions.contains(category),
        )
        .toList();
  }

  List<String> _extractDifficulties(Set<String> categories) {
    return categories
        .where(
          (String category) =>
              RecommendedCourseConstants.difficulties.contains(category),
        )
        .toList();
  }

  List<String> _extractRecommendationTypes(Set<String> categories) {
    return categories
        .where(
          (String category) =>
              RecommendedCourseConstants.recommendationTypes.contains(category),
        )
        .toList();
  }
}
