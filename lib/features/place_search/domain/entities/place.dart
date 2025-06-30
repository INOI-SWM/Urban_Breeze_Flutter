class Place {
  const Place({
    required this.title,
    required this.address,
    required this.roadAddress,
    required this.latitude,
    required this.longitude,
    this.category,
    this.description,
    this.telephone,
  });

  final String title;
  final String address;
  final String roadAddress;
  final double latitude;
  final double longitude;
  final String? category;
  final String? description;
  final String? telephone;

  @override
  String toString() {
    return 'Place(title: $title, address: $address, lat: $latitude, lng: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Place &&
        other.title == title &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        address.hashCode ^
        latitude.hashCode ^
        longitude.hashCode;
  }
}
