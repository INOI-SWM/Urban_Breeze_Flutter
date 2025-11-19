import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/recommended_course/domain/repositories/recommended_course_repository.dart';

class GetCourseTcxUseCase {
  const GetCourseTcxUseCase({required RecommendedCourseRepository repository})
    : _repository = repository;

  final RecommendedCourseRepository _repository;

  /// 추천코스 TCX 데이터 조회
  Future<AppResult<String>> execute({required String courseId}) async {
    try {
      final String tcxData = await _repository.getCourseTCX(courseId);
      return AppSuccess<String>(tcxData);
    } catch (e) {
      return AppFailure<String>(NetworkException(e.toString()));
    }
  }
}
