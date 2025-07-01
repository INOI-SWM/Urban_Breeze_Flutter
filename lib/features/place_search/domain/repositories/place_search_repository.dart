import '../entities/place.dart';

abstract class PlaceSearchRepository {
  Future<List<Place>> searchPlaces({required String query, int display = 5});
}
