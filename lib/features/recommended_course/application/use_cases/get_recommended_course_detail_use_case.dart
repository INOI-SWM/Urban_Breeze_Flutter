import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/exceptions/validation_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_detail.dart';
import 'package:urban_breeze/features/recommended_course/domain/repositories/recommended_course_repository.dart';

class GetRecommendedCourseDetailUseCase {
  const GetRecommendedCourseDetailUseCase({required this.repository});

  final RecommendedCourseRepository repository;

  Future<AppResult<RecommendedCourseDetail>> execute(String routeId) async {
    try {
      if (routeId.isEmpty) {
        return const AppFailure<RecommendedCourseDetail>(
          ValidationException(
            code: 'INVALID_ROUTE_ID',
            message: '경로 ID가 유효하지 않습니다',
          ),
        );
      }

      final RecommendedCourseDetail courseDetail = await repository
          .getCourseDetail(routeId);
      return AppSuccess<RecommendedCourseDetail>(courseDetail);
    } on NetworkException catch (e) {
      return AppFailure<RecommendedCourseDetail>(e);
    } on ServerException catch (e) {
      return AppFailure<RecommendedCourseDetail>(e);
    } catch (e) {
      return AppFailure<RecommendedCourseDetail>(
        ServerException('추천 코스 상세 정보를 불러올 수 없습니다: ${e.toString()}'),
      );
    }
  }
}
