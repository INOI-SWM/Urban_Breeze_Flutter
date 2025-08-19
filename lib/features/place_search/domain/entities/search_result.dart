import 'package:urban_breeze/features/place_search/domain/entities/place.dart';

class SearchResultBbox {
  const SearchResultBbox({
    required this.minLon,
    required this.minLat,
    required this.maxLon,
    required this.maxLat,
    required this.midLon,
    required this.midLat,
  });

  final double minLon;
  final double minLat;
  final double maxLon;
  final double maxLat;
  final double midLon;
  final double midLat;
}

class SearchResult {
  const SearchResult({required this.query, required this.places, this.bbox});

  final String query;
  final List<Place> places;
  final SearchResultBbox? bbox;
}
