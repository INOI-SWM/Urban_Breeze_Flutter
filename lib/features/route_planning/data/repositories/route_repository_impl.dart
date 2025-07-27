import 'package:ridingmate/features/route_planning/data/datasources/remote/route_remote_datasource.dart';
import 'package:ridingmate/features/route_planning/data/models/route_save_request_model.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_repository.dart';

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
    required List<double> elevations,
  }) async {
    final RouteSaveRequestModel request = RouteSaveRequestModel(
      title: title,
      polyline: encodedPolyline,
      bbox: bbox,
      distance: distance,
      duration: duration,
      elevationGain: elevationGain,
      elevations: elevations,
    );

    await _routeRemoteDataSource.saveRoute(request);
  }
}
