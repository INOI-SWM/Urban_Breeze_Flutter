import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/exceptions/route_exceptions.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_repository.dart';

class CreateRouteUseCase {
  CreateRouteUseCase({required RouteRepository routeRepository})
    : _routeRepository = routeRepository;

  final RouteRepository _routeRepository;

  Future<RouteData?> execute(LatLng startPoint, LatLng endPoint) async {
    try {
      final RouteData? result = await _routeRepository.getRoute(
        startPoint,
        endPoint,
      );
      return result;
    } on RouteNetworkException {
      rethrow;
    } catch (e) {
      return null;
    }
  }
}
