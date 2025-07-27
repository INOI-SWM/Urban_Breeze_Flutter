import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/datasources/remote/route_segment_remote_datasource.dart';
import 'package:ridingmate/features/route_planning/data/mappers/route_mapper.dart';
import 'package:ridingmate/features/route_planning/data/models/route_segment_api_response_model.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_segment.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_segment_repository.dart';

class RouteSegmentRepositoryImpl implements RouteSegmentRepository {
  RouteSegmentRepositoryImpl({
    required RouteSegmentRemoteDataSource routeSegmentRemoteDataSource,
  }) : _routeSegmentRemoteDataSource = routeSegmentRemoteDataSource;

  final RouteSegmentRemoteDataSource _routeSegmentRemoteDataSource;

  @override
  Future<RouteSegment> getRouteSegment(
    LatLng start,
    LatLng end, {
    RouteMode mode = RouteMode.cyclingRoad,
  }) async {
    final RouteApiResponseModel dto = await _routeSegmentRemoteDataSource
        .fetchRoute(start, end, mode.apiValue);

    return RouteMapper.fromDto(dto);
  }
}
