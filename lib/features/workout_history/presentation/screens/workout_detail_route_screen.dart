import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/workout_history/domain/entities/location_data.dart';
import 'package:ridingmate/features/workout_history/domain/entities/workout_record.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:ridingmate/shared/design_system/widgets/info/info_item.dart';
import 'package:ridingmate/shared/map/common_map_widgets.dart';
import 'package:ridingmate/shared/map/map_constants.dart';

class WorkoutDetailRouteScreen extends StatelessWidget {
  const WorkoutDetailRouteScreen({super.key, required this.workoutRecord});

  final WorkoutRecord workoutRecord;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: CustomAppBar(
        title: '상세 경로',
        leading: CustomIconButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: <Widget>[
          _WorkoutDetailRouteMapWidget(workoutRecord: workoutRecord),
          _DraggableBottomSheet(workoutRecord: workoutRecord),
        ],
      ),
    );
  }
}

class _WorkoutDetailRouteMapWidget extends StatelessWidget {
  const _WorkoutDetailRouteMapWidget({required this.workoutRecord});

  final WorkoutRecord workoutRecord;

  static const LatLng _defaultCenter = MapConstants.seoulCityHall;
  static const double _defaultZoom = MapConstants.defaultZoom;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    final List<LatLng> routePoints = _convertLocationDataToLatLng(
      workoutRecord.locationData,
    );

    final CameraFit? cameraFit = _calculateCameraFit(routePoints);

    return FlutterMap(
      options: MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: _defaultZoom,
        initialCameraFit: cameraFit,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: <Widget>[
        CommonMapWidgets.createTileLayer(),
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
        if (routePoints.isNotEmpty)
          MarkerLayer(
            markers: <Marker>[
              Marker(
                point: routePoints.first,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.statusPositive,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
              Marker(
                point: routePoints.last,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.statusNegative,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        CommonMapWidgets.createAttributionWidget(),
      ],
    );
  }

  List<LatLng> _convertLocationDataToLatLng(List<LocationData> locationData) {
    return locationData
        .map((LocationData data) => LatLng(data.latitude, data.longitude))
        .toList();
  }

  CameraFit? _calculateCameraFit(List<LatLng> routePoints) {
    if (routePoints.isEmpty) {
      return null;
    }

    final LatLngBounds bounds = _calculateLatLngBounds(routePoints);
    return CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(20));
  }

  LatLngBounds _calculateLatLngBounds(List<LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      LatLng(minLat, minLng), // southwest
      LatLng(maxLat, maxLng), // northeast
    );
  }
}

class _DraggableBottomSheet extends StatelessWidget {
  const _DraggableBottomSheet({required this.workoutRecord});

  final WorkoutRecord workoutRecord;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.backgroundNormalNormal,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: colors.lineNormalNormal,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: <Widget>[
                          _InfoCard(label: '평균 속도', value: '22.3 km/h'),
                          SizedBox(width: 8),
                          _InfoCard(label: '상승 고도', value: '124m'),
                          SizedBox(width: 8),
                          _InfoCard(label: '평균 심박수', value: '124bpm'),
                          SizedBox(width: 8),
                          _InfoCard(label: '평균 심박수', value: '124bpm'),
                        ],
                      ),
                    ),
                    SizedBox(height: 200),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Container(
      alignment: Alignment.centerLeft,
      width: 100,
      height: 70,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.backgroundNormalNormal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lineNormalNeutral),
      ),
      child: InfoItem(
        label: label,
        value: value,
        alignment: CrossAxisAlignment.start,
      ),
    );
  }
}
