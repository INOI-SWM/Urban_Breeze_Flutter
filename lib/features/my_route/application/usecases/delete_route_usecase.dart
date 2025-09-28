import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/my_route/domain/repositories/my_route_repository.dart';

class DeleteRouteUseCase {
  const DeleteRouteUseCase({required MyRouteRepository repository})
    : _repository = repository;

  final MyRouteRepository _repository;

  Future<AppResult<void>> execute(String routeId) async {
    try {
      await _repository.deleteRoute(routeId);
      return const AppSuccess<void>(null);
    } on NetworkException catch (e) {
      return AppFailure<void>(e);
    } on ServerException catch (e) {
      return AppFailure<void>(e);
    } catch (e) {
      return AppFailure<void>(
        ServerException('경로 삭제에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
