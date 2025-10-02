class ActivityImageModel {
  const ActivityImageModel({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
  });

  factory ActivityImageModel.fromJson(Map<String, dynamic> json) {
    return ActivityImageModel(
      id: json['id'] as int,
      imageUrl: json['imageUrl'] as String,
      displayOrder: json['displayOrder'] as int,
    );
  }

  final int id;
  final String imageUrl;
  final int displayOrder;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
    };
  }
}

class TrackPointModel {
  const TrackPointModel({
    required this.index,
    required this.elevation,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heartRate,
  });

  factory TrackPointModel.fromJson(Map<String, dynamic> json) {
    return TrackPointModel(
      index: json['index'] as int,
      elevation: (json['elevation'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      heartRate:
          json['heartRate'] != null
              ? (json['heartRate'] as num).toDouble()
              : null,
    );
  }

  final int index;
  final double elevation;
  final double latitude;
  final double longitude;
  final double? speed; // km/h
  final double? heartRate; // bpm

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'index': index,
      'elevation': elevation,
      'latitude': latitude,
      'longitude': longitude,
      if (speed != null) 'speed': speed,
      if (heartRate != null) 'heartRate': heartRate,
    };
  }
}

class WorkoutUserModel {
  const WorkoutUserModel({
    required this.uuid,
    required this.nickname,
    required this.profileImageUrl,
  });

  factory WorkoutUserModel.fromJson(Map<String, dynamic> json) {
    return WorkoutUserModel(
      uuid: json['uuid'] as String,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
    );
  }

  final String uuid;
  final String nickname;
  final String profileImageUrl;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uuid': uuid,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
    };
  }
}

class WorkoutDetailResponseModel {
  const WorkoutDetailResponseModel({
    required this.activityId,
    required this.title,
    required this.startedAt,
    required this.endedAt,
    required this.activeDurationMinutes,
    required this.totalDurationMinutes,
    required this.distance,
    required this.averageSpeed,
    this.elevationGain,
    this.elevationLoss,
    this.cadence,
    this.averageHeartRate,
    this.maxHeartRate,
    this.averagePower,
    this.maxPower,
    this.calories,
    required this.user,
    required this.thumbnailImageUrl,
    required this.activityImages,
    required this.trackPointsCount,
    required this.trackPoints,
    required this.bbox,
  });

  factory WorkoutDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutDetailResponseModel(
      activityId: json['activityId'] as String,
      title: json['title'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      activeDurationMinutes: json['activeDurationSeconds'] as int,
      totalDurationMinutes: json['totalDurationSeconds'] as int,
      distance: (json['distance'] as num).toDouble(), // km 단위
      averageSpeed: (json['averageSpeed'] as num).toDouble(),
      elevationGain: (json['elevationGain'] as num?)?.toDouble(),
      elevationLoss: (json['elevationLoss'] as num?)?.toDouble(),
      cadence: json['cadence'] as int?,
      averageHeartRate: json['averageHeartRate'] as int?,
      maxHeartRate: json['maxHeartRate'] as int?,
      averagePower: json['averagePower'] as int?,
      maxPower: json['maxPower'] as int?,
      calories: json['calories'] as int?,
      user: WorkoutUserModel.fromJson(json['user'] as Map<String, dynamic>),
      thumbnailImageUrl: json['thumbnailImageUrl'] as String,
      activityImages:
          (json['activityImages'] as List<dynamic>)
              .map(
                (dynamic item) =>
                    ActivityImageModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      trackPointsCount: json['trackPointsCount'] as int,
      trackPoints:
          (json['trackPoints'] as List<dynamic>)
              .map(
                (dynamic item) =>
                    TrackPointModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      bbox:
          (json['bbox'] as List<dynamic>)
              .map((dynamic item) => (item as num).toDouble())
              .toList(),
    );
  }

  final String activityId;
  final String title;
  final DateTime startedAt;
  final DateTime endedAt;
  final int activeDurationMinutes; // 초 단위 (API 필드명은 activeDurationSeconds로 변경됨)
  final int totalDurationMinutes; // 초 단위 (API 필드명은 totalDurationSeconds로 변경됨)
  final double distance; // km 단위
  final double averageSpeed; // km/h
  final double? elevationGain; // m
  final double? elevationLoss; // m
  final int? cadence; // rpm
  final int? averageHeartRate; // bpm
  final int? maxHeartRate; // bpm
  final int? averagePower; // W
  final int? maxPower; // W
  final int? calories; // kcal
  final WorkoutUserModel user;
  final String thumbnailImageUrl;
  final List<ActivityImageModel> activityImages;
  final int trackPointsCount;
  final List<TrackPointModel> trackPoints;
  final List<double> bbox; // [minLng, minLat, maxLng, maxLat]

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'activityId': activityId,
      'title': title,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'activeDurationSeconds': activeDurationMinutes,
      'totalDurationSeconds': totalDurationMinutes,
      'distance': distance, // km 단위
      'averageSpeed': averageSpeed,
      'elevationGain': elevationGain,
      'elevationLoss': elevationLoss,
      'cadence': cadence,
      'averageHeartRate': averageHeartRate,
      'maxHeartRate': maxHeartRate,
      'averagePower': averagePower,
      'maxPower': maxPower,
      'calories': calories,
      'user': user.toJson(),
      'thumbnailImageUrl': thumbnailImageUrl,
      'activityImages':
          activityImages
              .map((ActivityImageModel image) => image.toJson())
              .toList(),
      'trackPointsCount': trackPointsCount,
      'trackPoints':
          trackPoints.map((TrackPointModel point) => point.toJson()).toList(),
      'bbox': bbox,
    };
  }
}
