import 'package:ridingmate/features/place_search/data/models/kakao_search_response_model.dart';

import '../../domain/entities/place.dart';
import '../../domain/exceptions/place_search_domain_exceptions.dart';
import '../../domain/repositories/place_search_repository.dart';
import '../datasources/kakao_search_datasource.dart';

class PlaceSearchRepositoryImpl implements PlaceSearchRepository {
  const PlaceSearchRepositoryImpl({required KakaoSearchDataSource dataSource})
    : _dataSource = dataSource;

  final KakaoSearchDataSource _dataSource;

  @override
  Future<List<Place>> searchPlaces({
    required String query,
    required double longitude,
    required double latitude,
  }) async {
    try {
      final KakaoSearchResponseModel response = await _dataSource.searchPlaces(
        query: query,
        longitude: longitude,
        latitude: latitude,
      );

      if (response.documents.isEmpty) {
        throw const NoResultsException('검색 결과가 없습니다');
      }

      // 응답 데이터를 Place 엔티티로 변환
      final List<Place> places =
          response.documents
              .map((KakaoSearchDocument document) => document.toPlace())
              .where((Place place) => _isValidPlace(place))
              .toList();

      if (places.isEmpty) {
        throw const NoResultsException('유효한 장소 정보가 없습니다');
      }

      return places;
    } catch (e) {
      if (e is PlaceSearchDomainException) {
        rethrow;
      }

      throw PlaceSearchParsingException('검색 중 오류가 발생했습니다: ${e.toString()}');
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
