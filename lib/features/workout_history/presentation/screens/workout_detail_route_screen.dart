import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/location_data.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_record.dart';
import 'package:urban_breeze/shared/chart/common_line_chart_widget.dart';
import 'package:urban_breeze/shared/chart/workout_data_extractor.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_item.dart';
import 'package:urban_breeze/shared/map/common_map_widgets.dart';
import 'package:urban_breeze/shared/map/map_constants.dart';

enum WorkoutDataType { speed, altitude, heartRate }

class _ChartConfig {
  const _ChartConfig({
    required this.unit,
    required this.emptyMessage,
    required this.colorGetter,
  });

  final String unit;
  final String emptyMessage;
  final Color Function(SemanticColors colors) colorGetter;

  static const Map<WorkoutDataType, _ChartConfig> configs =
      <WorkoutDataType, _ChartConfig>{
        WorkoutDataType.speed: _ChartConfig(
          unit: '',
          emptyMessage: '속도 데이터 없음',
          colorGetter: _getSpeedColor,
        ),
        WorkoutDataType.altitude: _ChartConfig(
          unit: 'm',
          emptyMessage: '고도 데이터 없음',
          colorGetter: _getAltitudeColor,
        ),
        WorkoutDataType.heartRate: _ChartConfig(
          unit: '',
          emptyMessage: '심박수 데이터 없음',
          colorGetter: _getHeartRateColor,
        ),
      };

  static Color _getSpeedColor(SemanticColors colors) => colors.primaryNormal;
  static Color _getAltitudeColor(SemanticColors colors) =>
      colors.statusCautionary;
  static Color _getHeartRateColor(SemanticColors colors) =>
      colors.statusNegative;
}

class WorkoutDetailRouteScreen extends StatefulWidget {
  const WorkoutDetailRouteScreen({super.key, required this.workoutRecord});

  final WorkoutRecord workoutRecord;

  @override
  State<WorkoutDetailRouteScreen> createState() =>
      _WorkoutDetailRouteScreenState();
}

class _WorkoutDetailRouteScreenState extends State<WorkoutDetailRouteScreen> {
  final MapController _mapController = MapController();
  bool _hasUserDraggedMap = false;

  void _updateMapBounds(double bottomSheetSize) {
    if (_hasUserDraggedMap) return;

    final List<LatLng> routePoints =
        widget.workoutRecord.locationData
            ?.map((LocationData data) => LatLng(data.latitude, data.longitude))
            .toList() ??
        <LatLng>[];

    if (routePoints.isNotEmpty) {
      final LatLngBounds bounds = _calculateLatLngBounds(
        routePoints,
        bottomSheetSize,
      );
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(30)),
      );
    }
  }

  LatLngBounds _calculateLatLngBounds(
    List<LatLng> points,
    double bottomSheetSize,
  ) {
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

    final double expansionFactor = bottomSheetSize * 2.4;
    final double adjustedMinLat = minLat - (latDiff * expansionFactor);

    return LatLngBounds(LatLng(adjustedMinLat, minLng), LatLng(maxLat, maxLng));
  }

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
          _WorkoutDetailRouteMapWidget(
            workoutRecord: widget.workoutRecord,
            mapController: _mapController,
            onMapDragged: () {
              setState(() {
                _hasUserDraggedMap = true;
              });
            },
            calculateBounds: _calculateLatLngBounds,
          ),
          _DraggableBottomSheet(
            workoutRecord: widget.workoutRecord,
            onSizeChanged: (double size) {
              _updateMapBounds(size);
            },
          ),
        ],
      ),
    );
  }
}

class _WorkoutDetailRouteMapWidget extends StatelessWidget {
  const _WorkoutDetailRouteMapWidget({
    required this.workoutRecord,
    required this.mapController,
    required this.onMapDragged,
    required this.calculateBounds,
  });

  final WorkoutRecord workoutRecord;
  final MapController mapController;
  final VoidCallback onMapDragged;
  final LatLngBounds Function(List<LatLng>, double) calculateBounds;

  static const LatLng _defaultCenter = MapConstants.seoulCityHall;
  static const double _defaultZoom = MapConstants.defaultZoom;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final List<LatLng> routePoints =
        workoutRecord.locationData
            ?.map((LocationData data) => LatLng(data.latitude, data.longitude))
            .toList() ??
        <LatLng>[];

    CameraFit? initialCameraFit;
    if (routePoints.isNotEmpty) {
      final LatLngBounds bounds = calculateBounds(routePoints, 0.5);
      initialCameraFit = CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(30),
      );
    }

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: _defaultZoom,
        initialCameraFit: initialCameraFit,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onPositionChanged: (MapCamera position, bool hasGesture) {
          if (hasGesture) {
            onMapDragged();
          }
        },
      ),
      children: <Widget>[
        CommonMapWidgets.createTileLayer(),
        if (routePoints.isNotEmpty) ...<Widget>[
          PolylineLayer<LatLng>(
            polylines: <Polyline<LatLng>>[
              Polyline<LatLng>(
                points: routePoints,
                color: colors.primaryNormal,
                strokeWidth: MapConstants.polylineStrokeWidth,
              ),
            ],
          ),
          MarkerLayer(
            markers: <Marker>[
              _createMarker(routePoints.first, colors.statusPositive),
              _createMarker(routePoints.last, colors.statusNegative),
            ],
          ),
        ],
        CommonMapWidgets.createAttributionWidget(),
      ],
    );
  }

  //TODO: 디자인 수정 필요
  Marker _createMarker(LatLng point, Color color) {
    return Marker(
      point: point,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

class _DraggableBottomSheet extends StatefulWidget {
  const _DraggableBottomSheet({
    required this.workoutRecord,
    required this.onSizeChanged,
  });

  final WorkoutRecord workoutRecord;
  final ValueChanged<double> onSizeChanged;

  @override
  State<_DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<_DraggableBottomSheet> {
  int _selectedCardIndex = 0;

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

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (DraggableScrollableNotification notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSizeChanged(notification.extent);
        });
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: _initialChildSize,
        minChildSize: minChildSize.clamp(
          _minChildSizeLimit,
          _maxChildSizeLimit,
        ),
        maxChildSize: _maxChildSize,
        snap: true,
        snapSizes: <double>[
          minChildSize.clamp(_minChildSizeLimit, _maxChildSizeLimit),
          _maxChildSize,
        ],
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
                          Container(
                            width: _dragHandleWidth,
                            height: _dragHandleHeight,
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            decoration: BoxDecoration(
                              color: colors.lineNormalNormal,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: <Widget>[
                                _InfoCard(
                                  label: '평균 속도',
                                  value: '22.3 km/h',
                                  isSelected: _selectedCardIndex == 0,
                                  onTap:
                                      () => setState(() {
                                        _selectedCardIndex = 0;
                                      }),
                                ),
                                const SizedBox(width: 8),
                                _InfoCard(
                                  label: '상승 고도',
                                  value: '124m',
                                  isSelected: _selectedCardIndex == 1,
                                  onTap:
                                      () => setState(() {
                                        _selectedCardIndex = 1;
                                      }),
                                ),
                                const SizedBox(width: 8),
                                _InfoCard(
                                  label: '평균 심박수',
                                  value: '124bpm',
                                  isSelected: _selectedCardIndex == 2,
                                  onTap:
                                      () => setState(() {
                                        _selectedCardIndex = 2;
                                      }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          _WorkoutChart(
                            workoutRecord: widget.workoutRecord,
                            selectedIndex: _selectedCardIndex,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  static const double _cardWidth = 100.0;
  static const double _cardHeight = 70.0;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.centerLeft,
        width: _cardWidth,
        height: _cardHeight,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              isSelected ? colors.primaryNormal : colors.backgroundNormalNormal,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.lineNormalNeutral),
        ),
        child: InfoItem(
          label: label,
          value: value,
          alignment: CrossAxisAlignment.start,
          labelColor: isSelected ? colors.staticWhite : null,
          valueColor: isSelected ? colors.staticWhite : null,
        ),
      ),
    );
  }
}

class _WorkoutChart extends StatelessWidget {
  const _WorkoutChart({
    required this.workoutRecord,
    required this.selectedIndex,
  });

  final WorkoutRecord workoutRecord;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final WorkoutDataType dataType = WorkoutDataType.values[selectedIndex];
    final _ChartConfig config = _ChartConfig.configs[dataType]!;

    final List<FlSpot> spots = switch (dataType) {
      WorkoutDataType.speed => WorkoutDataExtractor.extractSpeedData(
        workoutRecord,
      ),
      WorkoutDataType.altitude => WorkoutDataExtractor.extractAltitudeData(
        workoutRecord,
      ),
      WorkoutDataType.heartRate => WorkoutDataExtractor.extractHeartRateData(
        workoutRecord,
      ),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: CommonLineChartWidget(
        title: _getChartTitle(dataType),
        spots: spots,
        unit: config.unit,
        color: config.colorGetter(colors),
        emptyMessage: config.emptyMessage,
        height: 200,
        showTooltip: false,
      ),
    );
  }

  String _getChartTitle(WorkoutDataType dataType) {
    return switch (dataType) {
      WorkoutDataType.speed => '속도',
      WorkoutDataType.altitude => '고도',
      WorkoutDataType.heartRate => '심박수',
    };
  }
}
