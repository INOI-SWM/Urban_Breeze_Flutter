import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/features/route_planning/domain/repositories/location_repository.dart';

class GetCurrentLocationUseCase {
  const GetCurrentLocationUseCase({
    required LocationRepository locationRepository,
  }) : _locationRepository = locationRepository;

  final LocationRepository _locationRepository;

  Future<LatLng?> execute() async {
    final LatLng? position = await _locationRepository.getCurrentLocation();
    return position;
  }
}
