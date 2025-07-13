import 'package:latlong2/latlong.dart';

class RouteSegmentApiRequestModel {
  const RouteSegmentApiRequestModel({
    required this.start,
    required this.end,
    this.elevation = true,
  });

  final LatLng start;
  final LatLng end;
  final bool elevation;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'coordinates': <List<double>>[
      <double>[start.longitude, start.latitude],
      <double>[end.longitude, end.latitude],
    ],
    'elevation': elevation,
  };
}
