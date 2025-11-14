import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_segment.dart'
    as route_planning;
import 'package:urban_breeze/features/workout_history/domain/entities/track_point.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
import 'package:urban_breeze/shared/chart/common_line_chart_widget.dart';
import 'package:urban_breeze/shared/chart/workout_data_extractor.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_item.dart';
import 'package:urban_breeze/shared/layout/kakao_map_with_bottom_sheet_layout.dart';
import 'package:urban_breeze/shared/map/kakao_map_state_mixin.dart';

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
          unit: 'km/h',
          emptyMessage: '속도 데이터 없음',
          colorGetter: _getSpeedColor,
        ),
        WorkoutDataType.altitude: _ChartConfig(
          unit: 'm',
          emptyMessage: '고도 데이터 없음',
          colorGetter: _getAltitudeColor,
        ),
        WorkoutDataType.heartRate: _ChartConfig(
          unit: 'bpm',
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
  const WorkoutDetailRouteScreen({super.key, required this.workoutDetail});

  final WorkoutDetail workoutDetail;

  @override
  State<WorkoutDetailRouteScreen> createState() =>
      _WorkoutDetailRouteScreenState();
}

class _WorkoutDetailRouteScreenState extends State<WorkoutDetailRouteScreen>
    with KakaoMapStateMixin<WorkoutDetailRouteScreen> {
  Future<void> _updateMapBounds(double bottomSheetSize) async {
    if (widget.workoutDetail.bbox != null) {
      await updateMapBounds(
        widget.workoutDetail.bbox!,
        bottomSheetSize,
        context: context,
      );
    }
  }

  Future<void> _updateMapOverlays(
    WorkoutDetail workoutDetail,
    SemanticColors colors,
  ) async {
    if (mapOverlayService == null || !mounted) return;
    if (workoutDetail.trackPoints == null ||
        workoutDetail.trackPoints!.isEmpty) {
      return;
    }

    try {
      // 기존 오버레이 제거
      await clearAllOverlays();

      if (!mounted) return;

      // 경로 포인트 변환
      final List<latlong2.LatLng> routePoints =
          workoutDetail.trackPoints!
              .map(
                (TrackPoint point) =>
                    latlong2.LatLng(point.latitude, point.longitude),
              )
              .toList();

      if (routePoints.isNotEmpty) {
        // 폴리라인 추가
        final kakao.Route route = await mapOverlayService!.addRouteLine(
          route_planning.RouteSegment(
            points: routePoints,
            distance: workoutDetail.distance,
            duration: workoutDetail.totalDurationMinutes,
            elevationGain: workoutDetail.elevationGain ?? 0.0,
            bbox: workoutDetail.bbox ?? <double>[],
            elevations:
                workoutDetail.trackPoints!
                    .map((TrackPoint p) => p.elevation)
                    .toList(),
            originalGeometry:
                routePoints
                    .map(
                      (latlong2.LatLng p) => <double>[
                        p.longitude,
                        p.latitude,
                        0.0,
                      ],
                    )
                    .toList(),
          ),
        );
        if (mounted) {
          addRoute(route);
        }

        // 시작점 마커 추가
        final kakao.Poi startPoi = await mapOverlayService!.addStartMarker(
          routePoints.first,
          colors.statusPositive,
        );
        if (mounted) {
          addPoi(startPoi);
        }

        // 끝점 마커 추가
        if (routePoints.length > 1) {
          final kakao.Poi endPoi = await mapOverlayService!.addEndMarker(
            routePoints.last,
            colors.statusNegative,
          );
          if (mounted) {
            addPoi(endPoi);
          }
        }
      }
    } catch (e) {
      debugPrint('지도 오버레이 업데이트 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: KakaoMapWithBottomSheetLayout(
        showOptionButton: false,
        onMapReady: (kakao.KakaoMapController controller) async {
          initializeMap(controller, colors);

          // 지도 초기화 완료 대기
          await Future<void>.delayed(const Duration(milliseconds: 50));

          if (!mounted) return;
          await _updateMapBounds(0.5);
          _updateMapOverlays(widget.workoutDetail, colors);
        },
        onSizeChanged: (double size) {
          if (!mounted) return;
          _updateMapBounds(size);
        },
        onCameraMoveStart: (kakao.GestureType gestureType) {
          if (gestureType == kakao.GestureType.pan) {
            setUserDraggedMap(true);
          }
        },
        sheetChild: _DraggableBottomSheet(workoutDetail: widget.workoutDetail),
      ),
    );
  }
}

class _DraggableBottomSheet extends StatefulWidget {
  const _DraggableBottomSheet({required this.workoutDetail});

  final WorkoutDetail workoutDetail;

  @override
  State<_DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<_DraggableBottomSheet> {
  int _selectedCardIndex = 0;
  late List<WorkoutDataType> _availableDataTypes;

  @override
  void initState() {
    super.initState();
    _initializeAvailableDataTypes();
  }

  void _initializeAvailableDataTypes() {
    _availableDataTypes = <WorkoutDataType>[];

    // 속도 데이터 확인
    final List<FlSpot> speedData =
        WorkoutDataExtractor.extractSpeedDataFromDetail(widget.workoutDetail);
    if (speedData.isNotEmpty) {
      _availableDataTypes.add(WorkoutDataType.speed);
    }

    // 고도 데이터 확인
    final List<FlSpot> altitudeData =
        WorkoutDataExtractor.extractAltitudeDataFromDetail(
          widget.workoutDetail,
        );
    if (altitudeData.isNotEmpty) {
      _availableDataTypes.add(WorkoutDataType.altitude);
    }

    // 심박수 데이터 확인
    final List<FlSpot> heartRateData =
        WorkoutDataExtractor.extractHeartRateDataFromDetail(
          widget.workoutDetail,
        );
    if (heartRateData.isNotEmpty) {
      _availableDataTypes.add(WorkoutDataType.heartRate);
    }

    // 첫 번째 데이터 타입을 기본 선택으로 설정
    _selectedCardIndex = 0;
  }

  List<Widget> _buildInfoCards() {
    final List<Widget> cards = <Widget>[];

    for (int i = 0; i < _availableDataTypes.length; i++) {
      if (i > 0) {
        cards.add(const SizedBox(width: 8));
      }

      cards.add(_buildInfoCard(_availableDataTypes[i], i));
    }

    return cards;
  }

  Widget _buildInfoCard(WorkoutDataType dataType, int index) {
    final String label;
    final String value;

    switch (dataType) {
      case WorkoutDataType.speed:
        label = '평균 속도';
        value = '${widget.workoutDetail.averageSpeed.toStringAsFixed(1)} km/h';
        break;
      case WorkoutDataType.altitude:
        label = '상승 고도';
        value = '${widget.workoutDetail.elevationGain?.toStringAsFixed(0)}m';
        break;
      case WorkoutDataType.heartRate:
        label = '평균 심박수';
        value =
            widget.workoutDetail.averageHeartRate != null
                ? '${widget.workoutDetail.averageHeartRate}bpm'
                : '데이터 없음';
        break;
    }

    return _InfoCard(
      label: label,
      value: value,
      isSelected: _selectedCardIndex == index,
      onTap:
          () => setState(() {
            _selectedCardIndex = index;
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: <Widget>[
          if (_availableDataTypes.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: _buildInfoCards()),
            ),
          const SizedBox(height: 40),
          if (_availableDataTypes.isNotEmpty)
            _WorkoutChart(
              workoutDetail: widget.workoutDetail,
              availableDataTypes: _availableDataTypes,
              selectedIndex: _selectedCardIndex,
            ),
        ],
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
    required this.workoutDetail,
    required this.availableDataTypes,
    required this.selectedIndex,
  });

  final WorkoutDetail workoutDetail;
  final List<WorkoutDataType> availableDataTypes;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    if (availableDataTypes.isEmpty ||
        selectedIndex >= availableDataTypes.length) {
      return const SizedBox.shrink();
    }

    final WorkoutDataType dataType = availableDataTypes[selectedIndex];
    final _ChartConfig config = _ChartConfig.configs[dataType]!;

    final List<FlSpot> spots = switch (dataType) {
      WorkoutDataType.speed => WorkoutDataExtractor.extractSpeedDataFromDetail(
        workoutDetail,
      ),
      WorkoutDataType.altitude =>
        WorkoutDataExtractor.extractAltitudeDataFromDetail(workoutDetail),
      WorkoutDataType.heartRate =>
        WorkoutDataExtractor.extractHeartRateDataFromDetail(workoutDetail),
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
