import '../../domain/entities/place.dart';

class PlaceSearchResponseModel {
  const PlaceSearchResponseModel({
    this.code,
    required this.message,
    required this.data,
  });

  factory PlaceSearchResponseModel.fromJson(Map<String, dynamic> json) {
    return PlaceSearchResponseModel(
      code: json['code']?.toString(),
      message: json['message']?.toString() ?? '',
      data: PlaceSearchData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  final String message;
  final PlaceSearchData data;
  final String? code;
}

class PlaceSearchData {
  const PlaceSearchData({required this.bbox, required this.documents});

  factory PlaceSearchData.fromJson(Map<String, dynamic> json) {
    return PlaceSearchData(
      bbox: PlaceSearchBbox.fromJson(json['bbox'] as Map<String, dynamic>),
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map(
                (dynamic document) => PlaceSearchDocument.fromJson(
                  document as Map<String, dynamic>,
                ),
              )
              .toList() ??
          <PlaceSearchDocument>[],
    );
  }

  final PlaceSearchBbox bbox;
  final List<PlaceSearchDocument> documents;
}

class PlaceSearchBbox {
  const PlaceSearchBbox({
    required this.minLon,
    required this.minLat,
    required this.maxLon,
    required this.maxLat,
    required this.midLon,
    required this.midLat,
  });

  factory PlaceSearchBbox.fromJson(Map<String, dynamic> json) {
    return PlaceSearchBbox(
      minLon: (json['minLon'] as num?)?.toDouble() ?? 0.0,
      minLat: (json['minLat'] as num?)?.toDouble() ?? 0.0,
      maxLon: (json['maxLon'] as num?)?.toDouble() ?? 0.0,
      maxLat: (json['maxLat'] as num?)?.toDouble() ?? 0.0,
      midLon: (json['midLon'] as num?)?.toDouble() ?? 0.0,
      midLat: (json['midLat'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final double minLon;
  final double minLat;
  final double maxLon;
  final double maxLat;
  final double midLon;
  final double midLat;
}

class PlaceSearchDocument {
  const PlaceSearchDocument({
    required this.placeName,
    required this.distance,
    required this.placeUrl,
    required this.addressName,
    required this.phone,
    required this.categoryGroupName,
    required this.x,
    required this.y,
  });

  factory PlaceSearchDocument.fromJson(Map<String, dynamic> json) {
    return PlaceSearchDocument(
      placeName: json['place_name']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '',
      placeUrl: json['place_url']?.toString() ?? '',
      addressName: json['address_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      categoryGroupName: json['category_group_name']?.toString() ?? '',
      x: json['x']?.toString() ?? '',
      y: json['y']?.toString() ?? '',
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
