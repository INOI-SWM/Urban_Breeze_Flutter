import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/my_route/domain/repositories/my_route_repository.dart';

class GetRouteGpxUseCase {
  const GetRouteGpxUseCase({required MyRouteRepository repository})
    : _repository = repository;

  final MyRouteRepository _repository;

  /// 경로 GPX 데이터 조회
  Future<AppResult<String>> execute({required String routeId}) async {
    try {
      final String gpxData = await _repository.getRouteGPX(routeId);
      return AppSuccess<String>(gpxData);
    } catch (e) {
      return AppFailure<String>(NetworkException(e.toString()));
    }
  }
}
