import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/exceptions/validation_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/recommended_course/domain/repositories/recommended_course_repository.dart';

class AddToMyRouteUseCase {
  const AddToMyRouteUseCase({required this.repository});

  final RecommendedCourseRepository repository;

  Future<AppResult<void>> execute(String routeId) async {
    try {
      if (routeId.isEmpty) {
        return const AppFailure<void>(
          ValidationException(
            code: 'INVALID_ROUTE_ID',
            message: '경로 ID가 유효하지 않습니다',
          ),
        );
      }

      await repository.addToMyRoute(routeId);
      return const AppSuccess<void>(null);
    } on NetworkException catch (e) {
      return AppFailure<void>(e);
    } on ServerException catch (e) {
      return AppFailure<void>(e);
    } catch (e) {
      return AppFailure<void>(
        ServerException('내 코스에 추가할 수 없습니다: ${e.toString()}'),
      );
    }
  }
}
