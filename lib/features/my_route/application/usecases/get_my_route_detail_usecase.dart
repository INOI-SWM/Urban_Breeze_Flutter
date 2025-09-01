import 'package:urban_breeze/features/my_route/domain/entities/my_route_detail.dart';
import 'package:urban_breeze/features/my_route/domain/repositories/my_route_repository.dart';

class GetMyRouteDetailUseCase {
  const GetMyRouteDetailUseCase({required MyRouteRepository repository})
    : _repository = repository;

  final MyRouteRepository _repository;

  Future<MyRouteDetail> call(String routeId) async {
    return await _repository.getRouteDetail(routeId);
  }
}
