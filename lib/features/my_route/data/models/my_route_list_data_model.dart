import 'package:urban_breeze/features/my_route/data/models/my_route_filter_rage_model.dart';
import 'package:urban_breeze/features/my_route/data/models/my_route_model.dart';
import 'package:urban_breeze/features/my_route/data/models/pagination_model.dart';

class MyRouteListDataModel {
  const MyRouteListDataModel({
    required this.routes,
    required this.pagination,
    required this.filterRange,
  });

  factory MyRouteListDataModel.fromJson(Map<String, dynamic> json) {
    return MyRouteListDataModel(
      routes:
          (json['routes'] as List<dynamic>)
              .map(
                (dynamic item) =>
                    MyRouteModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
      filterRange: MyRouteFilterRangeModel.fromJson(
        json['filterRange'] as Map<String, dynamic>,
      ),
    );
  }

  final List<MyRouteModel> routes;
  final PaginationModel pagination;
  final MyRouteFilterRangeModel filterRange;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'routes': routes.map((MyRouteModel route) => route.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
