class RouteSaveResponseModel {
  factory RouteSaveResponseModel.fromJson(Map<String, dynamic> json) {
    return RouteSaveResponseModel(
      routeId: json['data']['routeId'],
      title: json['data']['title'],
      totalDuration: json['data']['totalDuration'],
      totalDistance: json['data']['totalDistance'],
      totalElevationGain: json['data']['totalElevationGain'],
    );
  }
  const RouteSaveResponseModel({
    required this.routeId,
    required this.title,
    required this.totalDuration,
    required this.totalDistance,
    required this.totalElevationGain,
  });

  final int routeId;
  final String title;
  final int totalDuration;
  final int totalDistance;
  final int totalElevationGain;
}
