import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/datasources/route_remote_datasource.dart';
import 'package:ridingmate/features/route_planning/data/exceptions/route_exceptions.dart'
    as data_exceptions;
import 'package:ridingmate/features/route_planning/data/mappers/route_mapper.dart';
import 'package:ridingmate/features/route_planning/data/models/route_api_response_model.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/exceptions/route_domain_exceptions.dart'
    as domain_exceptions;
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
    try {
      final RouteApiResponseModel dto = await _remoteDataSource.fetchRoute(
        start,
        end,
        mode.apiValue,
      );

      return RouteMapper.fromDto(dto);
    } catch (e) {
      throw _mapToDomainException(e);
    }
  }

  domain_exceptions.RouteDomainException _mapToDomainException(
    Object exception,
  ) {
    return switch (exception) {
      data_exceptions.RouteNetworkException(:final String message) =>
        domain_exceptions.RouteNetworkException(message),
      data_exceptions.RouteServerException(:final String message) =>
        domain_exceptions.RouteServerException(message),
      data_exceptions.RouteParsingException(:final String message) =>
        domain_exceptions.RouteParsingException(message),
      data_exceptions.RouteValidationException(:final String message) =>
        domain_exceptions.RouteValidationException(message),
      _ => const domain_exceptions.RouteServerException('경로 생성 중 오류가 발생했습니다.'),
    };
  }
}
