import '../../domain/entities/place.dart';

class FilterPlacesUseCase {
  const FilterPlacesUseCase();

  /// 띄어쓰기 차이를 무시하고 문자열이 같은 결과만 필터링
  List<Place> execute(List<Place> places, String query) {
    final String normalizedQuery = query.replaceAll(' ', '').toLowerCase();

    return places.where((Place place) {
      final String normalizedTitle =
          place.title.replaceAll(' ', '').toLowerCase();
      final String normalizedAddress =
          place.address.replaceAll(' ', '').toLowerCase();

      return normalizedTitle.contains(normalizedQuery) ||
          normalizedAddress.contains(normalizedQuery);
    }).toList();
  }
}
