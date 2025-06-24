import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/datasources/location_datasource.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
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
