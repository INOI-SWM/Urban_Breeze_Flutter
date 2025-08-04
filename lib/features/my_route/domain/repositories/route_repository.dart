import 'package:ridingmate/features/my_route/domain/entities/route_filter.dart';
import 'package:ridingmate/features/my_route/domain/entities/route_list.dart';

abstract class RouteRepository {
  Future<MyRouteList> getRouteList(MyRouteFilter filter);
}
