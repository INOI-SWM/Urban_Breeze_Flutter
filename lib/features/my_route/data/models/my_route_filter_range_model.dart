class MyRouteFilterRangeModel {
  factory MyRouteFilterRangeModel.fromJson(Map<String, dynamic> json) {
    return MyRouteFilterRangeModel(
      maxDistance: json['maxDistance'] as double,
      maxElevationGain: json['maxElevationGain'] as double,
    );
  }

  MyRouteFilterRangeModel({
    required this.maxDistance,
    required this.maxElevationGain,
  });

  final double maxDistance;
  final double maxElevationGain;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'maxDistance': maxDistance,
      'maxElevationGain': maxElevationGain,
    };
  }
}
