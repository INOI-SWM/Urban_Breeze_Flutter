import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/datasources/remote/route_remote_datasource.dart';
import 'package:ridingmate/features/route_planning/data/datasources/remote/route_segment_remote_datasource.dart';
import 'package:ridingmate/features/route_planning/data/mappers/route_mapper.dart';
import 'package:ridingmate/features/route_planning/data/models/route_api_response_model.dart';
import 'package:ridingmate/features/route_planning/data/models/route_save_request_model.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl({
    required RouteSegmentRemoteDatasource routeRemoteDataSource,
    required RouteRemoteDatasource routeSaveRemoteDataSource,
  }) : _routeRemoteDataSource = routeRemoteDataSource,
       _routeSaveRemoteDataSource = routeSaveRemoteDataSource;

  final RouteSegmentRemoteDatasource _routeRemoteDataSource;
  final RouteRemoteDatasource _routeSaveRemoteDataSource;

  @override
  Future<RouteData> getRoute(
    LatLng start,
    LatLng end, {
    RouteMode mode = RouteMode.cyclingRoad,
  }) async {
    final RouteApiResponseModel dto = await _routeRemoteDataSource.fetchRoute(
      start,
      end,
      mode.apiValue,
    );

    return RouteMapper.fromDto(dto);
  }

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
      name: title,
      polyline: encodedPolyline,
      bbox: bbox,
      distance: distance,
      duration: duration,
      elevationGain: elevationGain,
      elevations: elevations,
    );

    await _routeSaveRemoteDataSource.saveRoute(request);
  }
}
