import 'package:ridingmate/features/my_route/data/models/route_filter_model.dart';
import 'package:ridingmate/features/my_route/data/models/route_list_data_model.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

abstract class RouteRepository {
  Future<ApiResponseModel<RouteListDataModel>> getRouteList(
    RouteFilterModel filter,
  );
}
