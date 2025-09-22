import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/track_point.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/map/common_map_widgets.dart';
import 'package:urban_breeze/shared/map/map_constants.dart';

class WorkoutDetailMapWidget extends StatelessWidget {
  const WorkoutDetailMapWidget({super.key, required this.workoutDetail});

  final WorkoutDetail workoutDetail;

  static const LatLng _defaultCenter = MapConstants.seoulCityHall;
  static const double _defaultZoom = MapConstants.defaultZoom;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    final List<LatLng> routePoints = _convertTrackPointsToLatLng(
      workoutDetail.trackPoints,
    );
    final CameraFit? cameraFit = _calculateCameraFit();

    return FlutterMap(
      options: MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: _defaultZoom,
        initialCameraFit: cameraFit,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: <Widget>[
        CommonMapWidgets.createTileLayer(),
        // 운동 경로 폴리라인
        if (routePoints.isNotEmpty)
          PolylineLayer<LatLng>(
            polylines: <Polyline<LatLng>>[
              Polyline<LatLng>(
                points: routePoints,
                color: colors.primaryNormal,
                strokeWidth: MapConstants.polylineStrokeWidth,
              ),
            ],
          ),
        CommonMapWidgets.createAttributionWidget(),
      ],
    );
  }

  /// WorkoutDetail의 trackPoints를 LatLng 포인트들로 변환
  List<LatLng> _convertTrackPointsToLatLng(List<TrackPoint> trackPoints) {
    return trackPoints
        .map((TrackPoint point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  CameraFit? _calculateCameraFit() {
    final List<double> bbox = workoutDetail.bbox;
    final LatLngBounds bounds = LatLngBounds(
      LatLng(bbox[1], bbox[0]), // minLat, minLng
      LatLng(bbox[3], bbox[2]), // maxLat, maxLng
    );
    return CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(20));
  }
}
