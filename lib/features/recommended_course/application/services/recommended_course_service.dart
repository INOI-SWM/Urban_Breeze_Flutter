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
    int page = 0,
    int size = 20,
  }) async {
    try {
      // 필터를 도메인 필터로 변환
      final RecommendedCourseFilter filter = _convertToFilter(
        categoryFilter,
        sortType: sortType,
        userLat: userLat,
        userLon: userLon,
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
      print('추천 코스 API 호출 실패: $e');
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
    int page = 0,
    int size = 10, // API 기본값
  }) {
    // TODO: categoryFilter 파라미터를 실제 필터로 변환하는 로직 구현
    return RecommendedCourseFilter(
      page: page,
      size: size,
      sortType: sortType ?? 'NEAREST', // API 기본값
      minDistance: 0.0,
      maxDistance: 100.0,
      minElevation: 0.0,
      maxElevation: 1000.0,
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
      'courseType':
          course.recommendationType, // recommendationType을 courseType으로 매핑
      'region': course.region,
      'roadType':
          course.recommendationType, // recommendationType을 roadType으로도 매핑
      'scenery':
          course.recommendationType, // recommendationType을 scenery로도 매핑 (임시)
      'difficulty': course.difficulty,
    };
  }
}
