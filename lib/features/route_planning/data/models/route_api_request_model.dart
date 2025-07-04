import 'package:latlong2/latlong.dart';

class RouteApiRequestModel {
  factory RouteApiRequestModel.toJson(LatLng start, LatLng end) {
    return RouteApiRequestModel(start: start, end: end);
  }

  const RouteApiRequestModel({
    required this.start,
    required this.end,
    this.elevation = true,
  });

  final LatLng start;
  final LatLng end;
  final bool elevation;
}
