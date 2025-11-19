class MyRouteDetailModel {
  const MyRouteDetailModel({
    required this.routeId,
    required this.title,
    required this.polyline,
    required this.createdAt,
    required this.durationSeconds,
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
      routeId: json['routeId'] as String,
      title: json['title'] as String,
      polyline: json['polyline'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      durationSeconds: json['durationSeconds'] as int,
      distance: (json['distanceM'] as num).toDouble(),
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
    );
  }

  final String routeId;
  final String title;
  final String polyline;
  final DateTime createdAt;
  final int durationSeconds; // 초 단위
  final double distance;
  final double elevationGain;
  final String userId;
  final String nickname;
  final String profileImageUrl;
  final int trackPointsCount;
  final List<TrackPointModel> trackPoints;
  final List<double> bbox; // [minLng, minLat, maxLng, maxLat]

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'routeId': routeId,
      'title': title,
      'polyline': polyline,
      'createdAt': createdAt,
      'durationSeconds': durationSeconds,
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
  const TrackPointModel({
    required this.index,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    this.waypoint,
  });

  factory TrackPointModel.fromJson(Map<String, dynamic> json) {
    return TrackPointModel(
      index: json['index'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      elevation: (json['elevation'] as num).toDouble(),
      waypoint:
          json['waypoint'] != null
              ? WaypointModel.fromJson(json['waypoint'] as Map<String, dynamic>)
              : null,
    );
  }

  final int index;
  final double latitude;
  final double longitude;
  final double elevation;
  final WaypointModel? waypoint;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'index': index,
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      if (waypoint != null) 'waypoint': waypoint!.toJson(),
    };
  }
}

class WaypointModel {
  const WaypointModel({required this.type, this.title, this.description});

  factory WaypointModel.fromJson(Map<String, dynamic> json) {
    return WaypointModel(
      type: json['type'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }

  final String type;
  final String? title;
  final String? description;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
    };
  }
}
