import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';

class RouteStatsUseCase {
  const RouteStatsUseCase();

  double getTotalDistance(List<RouteData> routeSegments) {
    return routeSegments.fold(
      0,
      (double sum, RouteData seg) => sum + seg.distance,
    );
  }

  double getTotalDuration(List<RouteData> routeSegments) {
    return routeSegments.fold(
      0,
      (double sum, RouteData seg) => sum + seg.duration,
    );
  }

  double getTotalElevationGain(List<RouteData> routeSegments) {
    return routeSegments.fold(
      0,
      (double sum, RouteData seg) => sum + seg.elevationGain,
    );
  }

  String getFormattedTotalDistance(List<RouteData> routeSegments) {
    return (getTotalDistance(routeSegments) / 1000).toStringAsFixed(2);
  }

  String getFormattedTotalDuration(List<RouteData> routeSegments) {
    final double totalDuration = getTotalDuration(routeSegments);
    final int minutes = (totalDuration / 60).floor();
    final int seconds = (totalDuration % 60).round();
    return '$minutes분 $seconds초';
  }

  String getFormattedElevationGain(List<RouteData> routeSegments) {
    return '${getTotalElevationGain(routeSegments).round()} m';
  }
}
