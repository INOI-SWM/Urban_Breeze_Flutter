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
    //TODO : api 연결 시 분 단위 계산으로 변경
    final double totalDuration = getTotalDuration(routeSegments);
    final int hours = (totalDuration / 3600).floor();
    final int minutes = ((totalDuration % 3600) / 60).floor();

    if (hours > 0) {
      return '$hours시간 $minutes분';
    } else {
      return '$minutes분';
    }
  }

  String getFormattedElevationGain(List<RouteData> routeSegments) {
    return '${getTotalElevationGain(routeSegments).round()} m';
  }
}
