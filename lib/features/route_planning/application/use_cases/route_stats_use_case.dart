import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';

class RouteStatsUseCase {
  const RouteStatsUseCase();

  double getTotalDistance(List<RouteData> routeSegments) {
    return routeSegments.fold(
      0,
      (double sum, RouteData seg) => sum + seg.distance,
    );
  }

  int getTotalDuration(List<RouteData> routeSegments) {
    return routeSegments.fold(
      0,
      (int sum, RouteData seg) => sum + seg.duration,
    );
  }

  double getTotalElevationGain(List<RouteData> routeSegments) {
    return routeSegments.fold(
      0,
      (double sum, RouteData seg) => sum + seg.elevationGain,
    );
  }

  String getFormattedTotalDistance(List<RouteData> routeSegments) {
    return formatDistance(getTotalDistance(routeSegments));
  }

  String getFormattedTotalDuration(List<RouteData> routeSegments) {
    return formatDuration(getTotalDuration(routeSegments));
  }

  String getFormattedElevationGain(List<RouteData> routeSegments) {
    return formatElevationGain(getTotalElevationGain(routeSegments));
  }

  String formatDistance(double distanceInMeters) {
    return (distanceInMeters / 1000).toStringAsFixed(2);
  }

  String formatDuration(int durationInMinutes) {
    final int hours = (durationInMinutes / 60).floor();
    final int minutes = ((durationInMinutes % 60)).floor();

    if (hours > 0) {
      return '$hours시간 $minutes분';
    } else {
      return '$minutes분';
    }
  }

  String formatElevationGain(double elevationGainInMeters) {
    return '${elevationGainInMeters.round()} m';
  }
}
