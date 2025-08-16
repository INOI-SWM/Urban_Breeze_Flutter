class RouteShareResponseModel {
  const RouteShareResponseModel({required this.shareUrl});

  factory RouteShareResponseModel.fromJson(Map<String, dynamic> json) {
    return RouteShareResponseModel(shareUrl: json['shareUrl'] as String);
  }

  final String shareUrl;
}
