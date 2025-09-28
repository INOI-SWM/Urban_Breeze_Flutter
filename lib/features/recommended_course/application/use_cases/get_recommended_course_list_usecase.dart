import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_filter.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_list.dart';
import 'package:urban_breeze/features/recommended_course/domain/repositories/recommended_course_repository.dart';

class GetRecommendedCourseListUseCase {
  const GetRecommendedCourseListUseCase({
    required RecommendedCourseRepository repository,
  }) : _repository = repository;

  final RecommendedCourseRepository _repository;

  Future<AppResult<RecommendedCourseList>> execute({
    RecommendedCourseFilter? filter,
  }) async {
    try {
      // 기본 필터 사용 (정렬: 가까운 순, 페이지: 0)
      final RecommendedCourseFilter filterModel =
          filter ?? const RecommendedCourseFilter();

      final RecommendedCourseList courseList = await _repository
          .getRecommendedCourseList(filterModel);
      return AppSuccess<RecommendedCourseList>(courseList);
    } catch (e) {
      return AppFailure<RecommendedCourseList>(NetworkException(e.toString()));
    }
  }
}
