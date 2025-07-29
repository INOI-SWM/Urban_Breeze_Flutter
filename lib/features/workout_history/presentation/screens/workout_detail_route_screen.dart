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
    return CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(30));
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

    final double latDiff = maxLat - minLat;

    final double adjustedMinLat = minLat - (latDiff * 1.2);

    return LatLngBounds(LatLng(adjustedMinLat, minLng), LatLng(maxLat, maxLng));
  }
}

class _DraggableBottomSheet extends StatelessWidget {
  const _DraggableBottomSheet({required this.workoutRecord});

  final WorkoutRecord workoutRecord;

  static const double _initialChildSize = 0.5;
  static const double _maxChildSize = 0.5;
  static const double _minChildSizeLimit = 0.1;
  static const double _maxChildSizeLimit = 0.3;

  static const double _dragHandleWidth = 40.0;
  static const double _dragHandleHeight = 4.0;
  static const double _dragHandleTotalHeight = 24.0;

  static const double _borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double bottomSafeArea = mediaQuery.viewPadding.bottom;
    final double totalScreenHeight = mediaQuery.size.height;

    const double minimumRequiredHeight =
        _dragHandleTotalHeight + _InfoCard._cardHeight + 20;
    final double minChildSize =
        (minimumRequiredHeight + bottomSafeArea) / totalScreenHeight;

    return DraggableScrollableSheet(
      initialChildSize: _initialChildSize,
      minChildSize: minChildSize.clamp(_minChildSizeLimit, _maxChildSizeLimit),
      maxChildSize: _maxChildSize,
      snap: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(_borderRadius),
            topRight: Radius.circular(_borderRadius),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colors.backgroundNormalNormal,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_borderRadius),
                topRight: Radius.circular(_borderRadius),
              ),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: <Widget>[
                        // 드래그 핸들
                        Container(
                          width: _dragHandleWidth,
                          height: _dragHandleHeight,
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          decoration: BoxDecoration(
                            color: colors.lineNormalNormal,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SingleChildScrollView(
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
                        // const SizedBox(height: 400),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

  // 카드 관련 주요 상수들 (여러 곳에서 재사용됨)
  static const double _cardWidth = 100.0;
  static const double _cardHeight = 70.0;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Container(
      alignment: Alignment.centerLeft,
      width: _cardWidth,
      height: _cardHeight,
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
