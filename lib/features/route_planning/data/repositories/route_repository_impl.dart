import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/datasources/route_remote_datasource.dart';
import 'package:ridingmate/features/route_planning/data/exceptions/route_exceptions.dart';
import 'package:ridingmate/features/route_planning/data/mappers/route_mapper.dart';
import 'package:ridingmate/features/route_planning/data/models/route_api_response_model.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl({required RouteRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final RouteRemoteDataSource _remoteDataSource;

  @override
  Future<RouteData?> getRoute(
    LatLng start,
    LatLng end, {
    RouteMode mode = RouteMode.cyclingRoad,
  }) async {
    try {
      final RouteApiResponseModel dto = await _remoteDataSource.fetchRoute(
        start,
        end,
        mode.apiValue,
      );

      return RouteMapper.fromDto(dto);
    } on RouteNetworkException {
      rethrow;
    } catch (e) {
      // 서버/파싱 오류 등은 UseCase에서 null로 처리될 예정
      return null;
    }
  }
}
