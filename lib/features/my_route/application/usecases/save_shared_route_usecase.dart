import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/exceptions/validation_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/my_route/domain/exceptions/route_share_exceptions.dart';
import 'package:urban_breeze/features/my_route/domain/repositories/my_route_repository.dart';

class SaveSharedRouteUseCase {
  const SaveSharedRouteUseCase({required this.repository});

  final MyRouteRepository repository;

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

      await repository.saveSharedRoute(routeId);
      return const AppSuccess<void>(null);
    } on RouteNotFoundException catch (e) {
      return AppFailure<void>(e);
    } on RouteAlreadyAddedException catch (e) {
      return AppFailure<void>(e);
    } on RouteAccessDeniedException catch (e) {
      return AppFailure<void>(e);
    } on NetworkException catch (e) {
      return AppFailure<void>(e);
    } on ServerException catch (e) {
      return AppFailure<void>(e);
    } catch (e) {
      return AppFailure<void>(
        ServerException('공유된 경로를 저장할 수 없습니다: ${e.toString()}'),
      );
    }
  }
}
