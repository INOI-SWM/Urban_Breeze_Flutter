import '../../domain/entities/place.dart';

class KakaoSearchResponseModel {
  const KakaoSearchResponseModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory KakaoSearchResponseModel.fromJson(Map<String, dynamic> json) {
    return KakaoSearchResponseModel(
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: KakaoSearchData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  final String code;
  final String message;
  final KakaoSearchData data;
}

class KakaoSearchData {
  const KakaoSearchData({required this.bbox, required this.documents});

  factory KakaoSearchData.fromJson(Map<String, dynamic> json) {
    return KakaoSearchData(
      bbox: json['bbox'] as String? ?? '',
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map(
                (dynamic document) => KakaoSearchDocument.fromJson(
                  document as Map<String, dynamic>,
                ),
              )
              .toList() ??
          <KakaoSearchDocument>[],
    );
  }

  final String bbox;
  final List<KakaoSearchDocument> documents;
}

class KakaoSearchDocument {
  const KakaoSearchDocument({
    required this.placeName,
    required this.distance,
    required this.placeUrl,
    required this.addressName,
    required this.phone,
    required this.categoryGroupName,
    required this.x,
    required this.y,
  });

  factory KakaoSearchDocument.fromJson(Map<String, dynamic> json) {
    return KakaoSearchDocument(
      placeName: json['place_name'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      placeUrl: json['place_url'] as String? ?? '',
      addressName: json['address_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      categoryGroupName: json['category_group_name'] as String? ?? '',
      x: json['x'] as String? ?? '',
      y: json['y'] as String? ?? '',
    );
  }

  final String placeName;
  final String distance;
  final String placeUrl;
  final String addressName;
  final String phone;
  final String categoryGroupName;
  final String x; // 경도
  final String y; // 위도

  // 응답 데이터를 Place 엔티티로 변환
  Place toPlace() {
    return Place(
      title: placeName,
      address: addressName,
      latitude: _parseCoordinate(y),
      longitude: _parseCoordinate(x),
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
