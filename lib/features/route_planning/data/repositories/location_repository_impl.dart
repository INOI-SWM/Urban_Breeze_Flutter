import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/datasources/location_datasource.dart';
import 'package:ridingmate/features/route_planning/domain/services/location_service.dart';

class LocationRepositoryImpl implements LocationService {
  const LocationRepositoryImpl({
    required GeolocatorLocationDataSource dataSource,
  }) : _dataSource = dataSource;

  final GeolocatorLocationDataSource _dataSource;

  @override
  Future<bool> checkAndRequestPermission() async {
    return await _dataSource.checkAndRequestPermission();
  }

  @override
  Future<LatLng?> getCurrentLocation() async {
    return await _dataSource.getCurrentLocation();
  }
}
