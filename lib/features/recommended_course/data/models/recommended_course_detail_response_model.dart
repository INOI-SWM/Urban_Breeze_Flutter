class RecommendedCourseDetailResponseModel {
  const RecommendedCourseDetailResponseModel({
    required this.routeId,
    required this.title,
    required this.description,
    required this.polyline,
    required this.createdAt,
    required this.durationMinutes,
    required this.distance,
    required this.elevationGain,
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
    required this.trackPointsCount,
    required this.trackPoints,
    required this.bbox,
    required this.recommendationType,
    required this.landscapeType,
    required this.region,
  });

  factory RecommendedCourseDetailResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecommendedCourseDetailResponseModel(
      routeId: json['routeId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      polyline: json['polyline'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      durationMinutes: json['durationMinutes'] as int,
      distance: (json['distance'] as num).toDouble(),
      elevationGain: (json['elevationGain'] as num).toDouble(),
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
      trackPointsCount: json['trackPointsCount'] as int,
      trackPoints:
          (json['trackPoints'] as List<dynamic>)
              .map(
                (dynamic e) =>
                    TrackPointModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      bbox:
          (json['bbox'] as List<dynamic>)
              .map((dynamic e) => (e as num).toDouble())
              .toList(),
      recommendationType: json['recommendationType'] as String,
      landscapeType: json['landscapeType'] as String,
      region: json['region'] as String,
    );
  }

  final String routeId;
  final String title;
  final String description;
  final String polyline;
  final DateTime createdAt;
  final int durationMinutes;
  final double distance;
  final double elevationGain;
  final String userId;
  final String nickname;
  final String profileImageUrl;
  final int trackPointsCount;
  final List<TrackPointModel> trackPoints;
  final List<double> bbox;
  final String recommendationType;
  final String landscapeType;
  final String region;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'routeId': routeId,
      'title': title,
      'description': description,
      'polyline': polyline,
      'createdAt': createdAt.toIso8601String(),
      'durationMinutes': durationMinutes,
      'distance': distance,
      'elevationGain': elevationGain,
      'userId': userId,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'trackPointsCount': trackPointsCount,
      'trackPoints':
          trackPoints.map((TrackPointModel e) => e.toJson()).toList(),
      'bbox': bbox,
      'recommendationType': recommendationType,
      'landscapeType': landscapeType,
      'region': region,
    };
  }
}

class TrackPointModel {
  const TrackPointModel({required this.index, required this.elevation});

  factory TrackPointModel.fromJson(Map<String, dynamic> json) {
    return TrackPointModel(
      index: json['index'] as int,
      elevation: (json['elevation'] as num).toDouble(),
    );
  }

  final int index;
  final double elevation;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'index': index, 'elevation': elevation};
  }
}
