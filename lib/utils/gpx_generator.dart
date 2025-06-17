import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';

import 'polyline_utils.dart';

class GpxGenerator {
  static String generateGPX(String encodedPolyline, String title) {
    final List<LatLng> coordinates = PolylineUtils.decodeToPoints(
      encodedPolyline,
    );

    final Gpx gpx = _buildGpx(title, coordinates);
    return GpxWriter().asString(gpx, pretty: true);
  }

  static Gpx _buildGpx(String title, List<LatLng> coordinates) {
    final Gpx gpx = Gpx();
    gpx.creator = 'RidingMate'; //todo : 추후 사용자 이름으로 변경
    gpx.metadata = Metadata(name: title, time: DateTime.now());
    gpx.wpts =
        coordinates
            .map(
              (LatLng point) => Wpt(lat: point.latitude, lon: point.longitude),
            )
            .toList();
    return gpx;
  }
}
