import '../../domain/entities/place.dart';

class NaverSearchResponse {
  const NaverSearchResponse({
    required this.lastBuildDate,
    required this.total,
    required this.start,
    required this.display,
    required this.items,
  });

  factory NaverSearchResponse.fromJson(Map<String, dynamic> json) {
    return NaverSearchResponse(
      lastBuildDate: json['lastBuildDate'] as String,
      total: json['total'] as int,
      start: json['start'] as int,
      display: json['display'] as int,
      items:
          (json['items'] as List<dynamic>)
              .map(
                (item) =>
                    NaverSearchItem.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  final String lastBuildDate;
  final int total;
  final int start;
  final int display;
  final List<NaverSearchItem> items;
}

class NaverSearchItem {
  const NaverSearchItem({
    required this.title,
    required this.link,
    required this.category,
    required this.description,
    required this.telephone,
    required this.address,
    required this.roadAddress,
    required this.mapx,
    required this.mapy,
  });

  factory NaverSearchItem.fromJson(Map<String, dynamic> json) {
    return NaverSearchItem(
      title: json['title'] as String,
      link: json['link'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      telephone: json['telephone'] as String,
      address: json['address'] as String,
      roadAddress: json['roadAddress'] as String,
      mapx: json['mapx'] as String,
      mapy: json['mapy'] as String,
    );
  }

  final String title;
  final String link;
  final String category;
  final String description;
  final String telephone;
  final String address;
  final String roadAddress;
  final String mapx;
  final String mapy;

  // 응답 데이터를 Place 엔티티로 변환
  Place toPlace() {
    return Place(
      title: _removeHtmlTags(title),
      address: address.isNotEmpty ? address : roadAddress,
      roadAddress: roadAddress.isNotEmpty ? roadAddress : address,
      latitude: _convertCoordinate(mapy),
      longitude: _convertCoordinate(mapx),
      category: category.isNotEmpty ? category : null,
      description: description.isNotEmpty ? _removeHtmlTags(description) : null,
      telephone: telephone.isNotEmpty ? telephone : null,
    );
  }

  // 응답에 포함되는 HTML 태그 제거
  String _removeHtmlTags(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // WGS84 좌표계를 실제 위도, 경도로 변환
  double _convertCoordinate(String coordinate) {
    final int intValue = int.tryParse(coordinate) ?? 0;
    return intValue / 10000000.0;
  }
}
