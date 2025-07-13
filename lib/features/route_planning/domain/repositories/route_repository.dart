abstract class RouteRepository {
  Future<void> saveRoute({
    required String title,
    required String encodedPolyline,
    required List<double> bbox,
    required double distance,
    required int duration,
    required double elevationGain,
    required List<double> elevations,
  });
}
