class MyRouteFilterRangeModel {
  factory MyRouteFilterRangeModel.fromJson(Map<String, dynamic> json) {
    return MyRouteFilterRangeModel(
      maxDistance: json['maxDistance'] as double,
      maxElevationGain: json['maxElevationGain'] as double,
      minDistance: json['minDistance'] as double,
      minElevationGain: json['minElevationGain'] as double,
    );
  }

  MyRouteFilterRangeModel({
    required this.maxDistance,
    required this.maxElevationGain,
    required this.minDistance,
    required this.minElevationGain,
  });

  final double maxDistance;
  final double minDistance;
  final double maxElevationGain;
  final double minElevationGain;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'maxDistance': maxDistance,
      'minDistance': minDistance,
      'maxElevationGain': maxElevationGain,
      'minElevationGain': minElevationGain,
    };
  }
}
