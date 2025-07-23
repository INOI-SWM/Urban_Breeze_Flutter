class Place {
  const Place({
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.id,
    this.category,
    this.categoryCode,
    this.description,
    this.telephone,
    this.placeUrl,
    this.distance,
  });

  final String? id; // 카카오 장소 고유 ID
  final String title; // 장소명
  final String address; // 지번 주소
  final double latitude; // 위도
  final double longitude; // 경도
  final String? category; // 상세 카테고리 (예: "음식점 > 한식")
  final String? categoryCode; // 카테고리 코드 (예: "FD6")
  final String? description; // 카테고리 그룹명 (예: "음식점")
  final String? telephone; // 전화번호
  final String? placeUrl; // 카카오맵 URL
  final String? distance; // 검색 중심점으로부터 거리

  @override
  String toString() {
    return 'Place(id: $id, title: $title, address: $address, lat: $latitude, lng: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Place &&
        other.id == id &&
        other.title == title &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        address.hashCode ^
        latitude.hashCode ^
        longitude.hashCode;
  }
}
