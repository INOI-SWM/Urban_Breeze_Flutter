import 'package:ridingmate/features/my_route/data/models/pagination_model.dart';
import 'package:ridingmate/features/my_route/data/models/route_model.dart';

class RouteListDataModel {
  const RouteListDataModel({required this.routes, required this.pagination});

  factory RouteListDataModel.fromJson(Map<String, dynamic> json) {
    return RouteListDataModel(
      routes:
          (json['routes'] as List<dynamic>)
              .map(
                (dynamic item) =>
                    RouteModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }

  final List<RouteModel> routes;
  final PaginationModel pagination;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'routes': routes.map((RouteModel route) => route.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
