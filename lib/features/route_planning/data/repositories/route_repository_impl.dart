import 'package:urban_breeze/features/route_planning/data/datasources/remote/route_remote_datasource.dart';
import 'package:urban_breeze/features/route_planning/data/models/geometry_point_model.dart';
import 'package:urban_breeze/features/route_planning/data/models/route_save_request_model.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/geometry_point.dart';
import 'package:urban_breeze/features/route_planning/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl({required RouteRemoteDataSource routeRemoteDataSource})
    : _routeRemoteDataSource = routeRemoteDataSource;

  final RouteRemoteDataSource _routeRemoteDataSource;

  @override
  Future<void> saveRoute({
    required String title,
    required String encodedPolyline,
    required List<double> bbox,
    required double distance,
    required int duration,
    required double elevationGain,
    required List<GeometryPoint> geometry,
  }) async {
    final RouteSaveRequestModel request = RouteSaveRequestModel(
      title: title,
      polyline: encodedPolyline,
      bbox: bbox,
      distance: distance,
      duration: duration,
      elevationGain: elevationGain,
      geometry:
          geometry
              .map(
                (GeometryPoint point) => GeometryPointModel.fromDomain(point),
              )
              .toList(),
    );

    await _routeRemoteDataSource.saveRoute(request);
  }
}
