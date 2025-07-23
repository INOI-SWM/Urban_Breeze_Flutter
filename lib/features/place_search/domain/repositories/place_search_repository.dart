import '../entities/search_result.dart';

abstract class PlaceSearchRepository {
  Future<SearchResult> searchPlaces({
    required String query,
    required double longitude,
    required double latitude,
  });
}
