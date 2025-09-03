import '../../domain/entities/place.dart';
import '../../domain/entities/search_result.dart';

class ProcessSearchResultsUseCase {
  const ProcessSearchResultsUseCase();

  /// 검색어 정규화 (앞뒤 공백 제거, 연속된 공백을 하나로 통합)
  String sanitizeQuery(String query) {
    return query.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// 중복 장소 제거
  List<Place> removeDuplicates(List<Place> places) {
    final Set<String> seen = <String>{};
    final List<Place> result = <Place>[];

    for (final Place place in places) {
      final String key = generateLocationKey(place.latitude, place.longitude);

      if (!seen.contains(key)) {
        seen.add(key);
        result.add(place);
      }
    }

    return result;
  }

  /// 위도,경도로 고유 키 생성, 소수점 5자리(약 1.1m 단위)까지만 고려
  /// 1.1m 단위까지 같으면 같은 장소로 간주
  String generateLocationKey(double latitude, double longitude) {
    final String lat = latitude.toStringAsFixed(5);
    final String lng = longitude.toStringAsFixed(5);
    return '$lat,$lng';
  }

  /// 검색 결과 전체 처리 (정규화, 중복 제거 등)
  SearchResult processSearchResults(SearchResult rawResults) {
    final String sanitizedQuery = sanitizeQuery(rawResults.query);
    final List<Place> uniquePlaces = removeDuplicates(rawResults.places);

    return SearchResult(
      query: sanitizedQuery,
      places: uniquePlaces,
      bbox: rawResults.bbox,
    );
  }
}
