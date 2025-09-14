class MyRouteDetailModel {
  const MyRouteDetailModel({
    required this.id,
    required this.title,
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
  });

  factory MyRouteDetailModel.fromJson(Map<String, dynamic> json) {
    return MyRouteDetailModel(
      id: json['id'] as int,
      title: json['title'] as String,
      polyline: json['polyline'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      durationMinutes: json['durationMinutes'] as int, // 분 단위
      distance: (json['distance'] as num).toDouble(),
      elevationGain: (json['elevationGain'] as num).toDouble(),
      userId: json['userId'] as int,
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
    );
  }

  final int id;
  final String title;
  final String polyline;
  final DateTime createdAt;
  final int durationMinutes;
  final double distance;
  final double elevationGain;
  final int userId;
  final String nickname;
  final String profileImageUrl;
  final int trackPointsCount;
  final List<TrackPointModel> trackPoints;
  final List<double> bbox; // [minLng, minLat, maxLng, maxLat]

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'polyline': polyline,
      'createdAt': createdAt,
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
