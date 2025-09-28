import 'package:urban_breeze/features/my_route/domain/entities/my_route_detail.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_filter.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_list.dart';

abstract class MyRouteRepository {
  Future<MyRouteList> getMyRouteList(MyRouteFilter filter);
  Future<MyRouteDetail> getRouteDetail(String routeId);
  Future<String> getRouteGPX(String routeId);
  Future<void> deleteRoute(String routeId);
}
