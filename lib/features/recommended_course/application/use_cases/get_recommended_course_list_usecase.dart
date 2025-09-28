import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_filter.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_list.dart';
import 'package:urban_breeze/features/recommended_course/domain/enums/course_sort_type.dart';
import 'package:urban_breeze/features/recommended_course/domain/repositories/recommended_course_repository.dart';
import 'package:urban_breeze/features/recommended_course/presentation/mappers/recommended_course_filter_mapper.dart';
import 'package:urban_breeze/shared/filter/models/filter_data.dart';
import 'package:urban_breeze/shared/filter/models/filter_item.dart';

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

      // 필터를 도메인 필터로 변환 (매퍼 사용)
      final RecommendedCourseFilter filter =
          RecommendedCourseFilterMapper.fromFilterData(
            filterData ?? FilterData.fromFilterItems(<FilterItem>[]),
            actualSortType,
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
}
