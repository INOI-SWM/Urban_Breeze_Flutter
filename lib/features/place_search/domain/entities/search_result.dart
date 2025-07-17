import 'package:ridingmate/features/place_search/domain/entities/place.dart';

class SearchResult {
  const SearchResult({required this.query, required this.places});

  final String query;
  final List<Place> places;
}
