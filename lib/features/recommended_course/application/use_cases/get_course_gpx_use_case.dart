import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/recommended_course/domain/repositories/recommended_course_repository.dart';

class GetCourseGpxUseCase {
  const GetCourseGpxUseCase({required RecommendedCourseRepository repository})
    : _repository = repository;

  final RecommendedCourseRepository _repository;

  /// 추천코스 GPX 데이터 조회
  Future<AppResult<String>> execute({required String courseId}) async {
    try {
      final String gpxData = await _repository.getCourseGPX(courseId);
      return AppSuccess<String>(gpxData);
    } catch (e) {
      return AppFailure<String>(NetworkException(e.toString()));
    }
  }
}
