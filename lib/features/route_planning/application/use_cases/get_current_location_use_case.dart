import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/application/services/location_service.dart';

class GetCurrentLocationUseCase {
  Future<LatLng?> execute() async {
    final LatLng? position = await LocationService.getCurrentLocation();
    return position;
  }
}
