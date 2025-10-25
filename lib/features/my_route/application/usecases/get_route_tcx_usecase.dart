import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/my_route/domain/repositories/my_route_repository.dart';

class GetRouteTcxUseCase {
  const GetRouteTcxUseCase({required MyRouteRepository repository})
    : _repository = repository;

  final MyRouteRepository _repository;

  /// 경로 TCX 데이터 조회
  Future<AppResult<String>> execute({required String routeId}) async {
    try {
      final String tcxData = await _repository.getRouteTCX(routeId);
      return AppSuccess<String>(tcxData);
    } catch (e) {
      return AppFailure<String>(NetworkException(e.toString()));
    }
  }
}
