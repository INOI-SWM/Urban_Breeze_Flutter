import 'package:latlong2/latlong.dart';

class MapConstants {
  MapConstants._();

  static const LatLng seoulCityHall = LatLng(37.5665, 126.9780);
  static const double defaultZoom = 13.0;
  static const double routePlanningZoom = 16.0;
  static const String userAgentPackageName = 'com.example.ridingmate';
  static const List<String> subdomains = <String>['a', 'b', 'c'];

  static const double polylineStrokeWidth = 4.0;

  static const String attributionText =
      'Powered by Geoapify | © OpenStreetMap contributors';
}
