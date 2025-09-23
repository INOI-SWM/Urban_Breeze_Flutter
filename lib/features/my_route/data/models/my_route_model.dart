class MyRouteModel {
  const MyRouteModel({
    required this.routeId,
    required this.title,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.distance,
    required this.elevationGain,
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
  });

  factory MyRouteModel.fromJson(Map<String, dynamic> json) {
    return MyRouteModel(
      routeId: json['routeId'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      createdAt: json['createdAt'] as String,
      distance: (json['distance'] as num).toDouble(),
      elevationGain: (json['elevationGain'] as num).toDouble(),
      userId: json['userId'] as int,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
    );
  }

  final String routeId;
  final String title;
  final String thumbnailUrl;
  final String createdAt;
  final double distance;
  final double elevationGain;
  final int userId;
  final String nickname;
  final String profileImageUrl;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'routeId': routeId,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt,
      'distance': distance,
      'elevationGain': elevationGain,
      'userId': userId,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
    };
  }
}
