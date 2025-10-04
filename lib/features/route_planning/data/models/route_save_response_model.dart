class RouteSaveResponseModel {
  factory RouteSaveResponseModel.fromJson(Map<String, dynamic> json) {
    return RouteSaveResponseModel(
      routeId: json['routeId'],
      title: json['title'],
      totalDuration: json['totalDurationSeconds'],
      totalDistanceM: json['totalDistanceM'],
      totalElevationGain: json['totalElevationGain'],
    );
  }
  const RouteSaveResponseModel({
    required this.routeId,
    required this.title,
    required this.totalDuration,
    required this.totalDistanceM,
    required this.totalElevationGain,
  });

  final String routeId;
  final String title;
  final int totalDuration; // 초
  final double totalDistanceM; //m
  final double totalElevationGain; //m
}
