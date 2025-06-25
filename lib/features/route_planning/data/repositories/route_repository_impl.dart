import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/datasources/route_remote_datasource.dart';
import 'package:ridingmate/features/route_planning/data/mappers/route_mapper.dart';
import 'package:ridingmate/features/route_planning/data/models/route_api_response_model.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl({required RouteRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final RouteRemoteDataSource _remoteDataSource;

  @override
  Future<RouteData> getRoute(
    LatLng start,
    LatLng end, {
    RouteMode mode = RouteMode.cyclingRoad,
  }) async {
    final RouteApiResponseModel dto = await _remoteDataSource.fetchRoute(
      start,
      end,
      mode.apiValue,
    );

    return RouteMapper.fromDto(dto);
  }
}
