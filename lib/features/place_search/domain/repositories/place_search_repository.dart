import '../entities/place.dart';

abstract class PlaceSearchRepository {
  Future<List<Place>> searchPlaces({
    required String query,
    required double longitude,
    required double latitude,
  });
}
