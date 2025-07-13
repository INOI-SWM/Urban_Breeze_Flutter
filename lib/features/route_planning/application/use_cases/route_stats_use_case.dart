import 'package:ridingmate/features/route_planning/domain/entities/route_segment.dart';

class RouteStatsUseCase {
  const RouteStatsUseCase();

  double getTotalDistance(List<RouteSegment> routeSegments) {
    return routeSegments.fold(
      0,
      (double sum, RouteSegment seg) => sum + seg.distance,
    );
  }

  int getTotalDuration(List<RouteSegment> routeSegments) {
    return routeSegments.fold(
      0,
      (int sum, RouteSegment seg) => sum + seg.duration,
    );
  }

  double getTotalElevationGain(List<RouteSegment> routeSegments) {
    return routeSegments.fold(
      0,
      (double sum, RouteSegment seg) => sum + seg.elevationGain,
    );
  }

  String getFormattedTotalDistance(List<RouteSegment> routeSegments) {
    return formatDistance(getTotalDistance(routeSegments));
  }

  String getFormattedTotalDuration(List<RouteSegment> routeSegments) {
    return formatDuration(getTotalDuration(routeSegments));
  }

  String getFormattedElevationGain(List<RouteSegment> routeSegments) {
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
