class RouteSaveResponseModel {
  factory RouteSaveResponseModel.fromJson(Map<String, dynamic> json) {
    return RouteSaveResponseModel(
      routeId: json['routeId'],
      title: json['title'],
      totalDuration: json['totalDuration'],
      totalDistance: json['totalDistance'],
      totalElevationGain: json['totalElevationGain'],
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
  final int totalDuration; // 분
  final double totalDistance; //km
  final double totalElevationGain; //m
}
