import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_repository.dart';

class CreateRouteUseCase {
  CreateRouteUseCase({required RouteRepository routeRepository})
    : _routeRepository = routeRepository;

  final RouteRepository _routeRepository;

  Future<RouteData> execute(LatLng startPoint, LatLng endPoint) async {
    return await _routeRepository.getRoute(startPoint, endPoint);
  }
}
