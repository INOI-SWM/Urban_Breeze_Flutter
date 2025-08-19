import 'package:urban_breeze/features/my_route/domain/entities/my_route_filter.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_list.dart';

abstract class MyRouteRepository {
  Future<MyRouteList> getMyRouteList(MyRouteFilter filter);
}
