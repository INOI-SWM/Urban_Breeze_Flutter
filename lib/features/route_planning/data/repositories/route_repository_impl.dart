import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/datasources/route_remote_datasource.dart';
import 'package:ridingmate/features/route_planning/data/exceptions/route_exceptions.dart';
import 'package:ridingmate/features/route_planning/data/mappers/route_mapper.dart';
import 'package:ridingmate/features/route_planning/data/models/route_api_response_model.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';

enum RouteMode {
  drivingCar,
  cyclingRegular,
  cyclingRoad,
  cyclingMountain,
  cyclingElectric,
}

extension RouteModeExtension on RouteMode {
  String get apiValue {
    switch (this) {
      case RouteMode.drivingCar:
        return 'driving-car';
      case RouteMode.cyclingRegular:
        return 'cycling-regular';
      case RouteMode.cyclingRoad:
        return 'cycling-road';
      case RouteMode.cyclingMountain:
        return 'cycling-mountain';
      case RouteMode.cyclingElectric:
        return 'cycling-electric';
    }
  }
}

abstract class RouteRepository {
  Future<RouteData?> getRoute(
    LatLng start,
    LatLng end, {
    RouteMode mode = RouteMode.cyclingRoad,
  });
}

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
    } on RouteValidationException {
      return null;
    } catch (e) {
      // TODO: 구체적인 예외 처리 및 로깅 추가
      return null;
    }
  }
}
