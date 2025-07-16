import '../../domain/entities/place.dart';

class KakaoSearchResponseModel {
  const KakaoSearchResponseModel({required this.meta, required this.documents});

  factory KakaoSearchResponseModel.fromJson(Map<String, dynamic> json) {
    return KakaoSearchResponseModel(
      meta: KakaoSearchMeta.fromJson(json['meta'] as Map<String, dynamic>),
      documents:
          (json['documents'] as List<dynamic>)
              .map(
                (dynamic document) => KakaoSearchDocument.fromJson(
                  document as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }

  final KakaoSearchMeta meta;
  final List<KakaoSearchDocument> documents;
}

class KakaoSearchMeta {
  const KakaoSearchMeta({
    required this.totalCount,
    required this.pageableCount,
    required this.isEnd,
  });

  factory KakaoSearchMeta.fromJson(Map<String, dynamic> json) {
    return KakaoSearchMeta(
      totalCount: json['total_count'] as int,
      pageableCount: json['pageable_count'] as int,
      isEnd: json['is_end'] as bool,
    );
  }

  final int totalCount;
  final int pageableCount;
  final bool isEnd;
}

class KakaoSearchDocument {
  const KakaoSearchDocument({
    required this.id,
    required this.placeName,
    required this.categoryName,
    required this.categoryGroupCode,
    required this.categoryGroupName,
    required this.phone,
    required this.addressName,
    required this.roadAddressName,
    required this.x,
    required this.y,
    required this.placeUrl,
    required this.distance,
  });

  factory KakaoSearchDocument.fromJson(Map<String, dynamic> json) {
    return KakaoSearchDocument(
      id: json['id'] as String,
      placeName: json['place_name'] as String,
      categoryName: json['category_name'] as String,
      categoryGroupCode: json['category_group_code'] as String,
      categoryGroupName: json['category_group_name'] as String,
      phone: json['phone'] as String,
      addressName: json['address_name'] as String,
      roadAddressName: json['road_address_name'] as String,
      x: json['x'] as String,
      y: json['y'] as String,
      placeUrl: json['place_url'] as String,
      distance: json['distance'] as String,
    );
  }

  final String id;
  final String placeName;
  final String categoryName;
  final String categoryGroupCode;
  final String categoryGroupName;
  final String phone;
  final String addressName;
  final String roadAddressName;
  final String x; // 경도
  final String y; // 위도
  final String placeUrl;
  final String distance;

  // 응답 데이터를 Place 엔티티로 변환
  Place toPlace() {
    return Place(
      id: id.isNotEmpty ? id : null,
      title: placeName,
      address: addressName.isNotEmpty ? addressName : roadAddressName,
      roadAddress: roadAddressName.isNotEmpty ? roadAddressName : addressName,
      latitude: _parseCoordinate(y),
      longitude: _parseCoordinate(x),
      category: categoryName.isNotEmpty ? categoryName : null,
      categoryCode: categoryGroupCode.isNotEmpty ? categoryGroupCode : null,
      description: categoryGroupName.isNotEmpty ? categoryGroupName : null,
      telephone: phone.isNotEmpty ? phone : null,
      placeUrl: placeUrl.isNotEmpty ? placeUrl : null,
      distance: distance.isNotEmpty ? distance : null,
    );
  }

  double _parseCoordinate(String coordinate) {
    return double.tryParse(coordinate) ?? 0.0;
  }
}
