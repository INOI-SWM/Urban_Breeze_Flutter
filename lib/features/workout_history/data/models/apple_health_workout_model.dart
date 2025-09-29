class AppleHealthWorkoutModel {
  const AppleHealthWorkoutModel({
    required this.externalId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.distance,
    required this.calories,
    required this.source,
    required this.title,
    this.heartRateData = const <HeartRateDataModel>[],
    this.locationData = const <LocationDataModel>[],
  });

  final String externalId;
  final String startTime;
  final String endTime;
  final int duration;
  final double distance;
  final int calories;
  final String source;
  final String title;
  final List<HeartRateDataModel> heartRateData;
  final List<LocationDataModel> locationData;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'externalId': externalId,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'distance': distance,
      'calories': calories,
      'source': source,
      'title': title,
      'heartRateData':
          heartRateData.map((HeartRateDataModel e) => e.toJson()).toList(),
      'locationData':
          locationData.map((LocationDataModel e) => e.toJson()).toList(),
    };
  }
}

class HeartRateDataModel {
  const HeartRateDataModel({required this.timestamp, required this.heartRate});

  final String timestamp;
  final int heartRate;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'timestamp': timestamp, 'heartRate': heartRate};
  }
}

class LocationDataModel {
  const LocationDataModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.altitude,
    required this.speed,
    required this.horizontalAccuracy,
    required this.verticalAccuracy,
    required this.course,
  });

  final double latitude;
  final double longitude;
  final String timestamp;
  final double altitude;
  final double speed;
  final double horizontalAccuracy;
  final double verticalAccuracy;
  final double course;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'altitude': altitude,
      'speed': speed,
      'horizontalAccuracy': horizontalAccuracy,
      'verticalAccuracy': verticalAccuracy,
      'course': course,
    };
  }
}

class ImportAppleHealthWorkoutsRequestModel {
  const ImportAppleHealthWorkoutsRequestModel({required this.workouts});

  final List<AppleHealthWorkoutModel> workouts;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'workouts':
          workouts.map((AppleHealthWorkoutModel e) => e.toJson()).toList(),
    };
  }
}
