import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/domain/services/location_service.dart';

class GetCurrentLocationUseCase {
  const GetCurrentLocationUseCase({required LocationService locationService})
    : _locationService = locationService;

  final LocationService _locationService;

  Future<LatLng?> execute() async {
    final LatLng? position = await _locationService.getCurrentLocation();
    return position;
  }
}
