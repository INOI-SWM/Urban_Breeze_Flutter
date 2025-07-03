import 'package:ridingmate/features/place_search/data/models/naver_search_response_model.dart';

import '../../domain/entities/place.dart';
import '../../domain/repositories/place_search_repository.dart';
import '../datasources/naver_search_datasource.dart';
import '../exceptions/place_search_exceptions.dart';

class PlaceSearchRepositoryImpl implements PlaceSearchRepository {
  const PlaceSearchRepositoryImpl({required NaverSearchDataSource dataSource})
    : _dataSource = dataSource;

  final NaverSearchDataSource _dataSource;

  @override
  Future<List<Place>> searchPlaces({
    required String query,
    int display = 5,
  }) async {
    try {
      final NaverSearchResponse response = await _dataSource.searchPlaces(
        query: query,
        display: display,
      );

      if (response.items.isEmpty) {
        throw const NoResultsException();
      }

      // 네이버 응답 데이터를 Place 엔티티로 변환
      final List<Place> places =
          response.items
              .map((NaverSearchItem item) => item.toPlace())
              .where((Place place) => _isValidPlace(place))
              .toList();

      if (places.isEmpty) {
        throw const NoResultsException();
      }

      return places;
    } catch (e) {
      if (e is PlaceSearchException) {
        rethrow;
      }

      throw ParseException('검색 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  bool _isValidPlace(Place place) {
    if (place.title.trim().isEmpty) {
      return false;
    }

    if (place.address.trim().isEmpty && place.roadAddress.trim().isEmpty) {
      return false;
    }

    if (!_isValidCoordinate(place.latitude, place.longitude)) {
      return false;
    }

    return true;
  }

  // 좌표가 한국 범위 내에 있는지 확인
  bool _isValidCoordinate(double latitude, double longitude) {
    return latitude >= 33.0 &&
        latitude <= 38.5 &&
        longitude >= 124.0 &&
        longitude <= 132.0;
  }
}
