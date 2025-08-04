import 'package:ridingmate/features/my_route/domain/entities/route.dart';
import 'package:ridingmate/features/my_route/domain/entities/route_filter.dart';
import 'package:ridingmate/features/my_route/domain/entities/route_list.dart';
import 'package:ridingmate/features/my_route/domain/repositories/route_repository.dart';

class GetRouteListUseCase {
  const GetRouteListUseCase({required RouteRepository repository})
    : _repository = repository;

  final RouteRepository _repository;

  Future<List<Route>> execute({RouteFilter? filter}) async {
    try {
      final RouteFilter filterModel = filter ?? const RouteFilter();
      final RouteList routeList = await _repository.getRouteList(filterModel);
      return routeList.routes;
    } catch (e) {
      // 에러 발생 시 빈 리스트 반환
      return <Route>[];
    }
  }
}
