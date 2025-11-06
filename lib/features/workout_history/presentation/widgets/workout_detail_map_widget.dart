import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_segment.dart'
    as route_planning;
import 'package:urban_breeze/features/workout_history/domain/entities/track_point.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/map/kakao_map_state_mixin.dart';

class WorkoutDetailMapWidget extends StatefulWidget {
  const WorkoutDetailMapWidget({super.key, required this.workoutDetail});

  final WorkoutDetail workoutDetail;

  @override
  State<WorkoutDetailMapWidget> createState() => _WorkoutDetailMapWidgetState();
}

class _WorkoutDetailMapWidgetState extends State<WorkoutDetailMapWidget>
    with KakaoMapStateMixin<WorkoutDetailMapWidget> {
  Future<void> _updateMapOverlays(
    WorkoutDetail workoutDetail,
    SemanticColors colors,
  ) async {
    if (mapOverlayService == null || !mounted) return;

    try {
      // 기존 오버레이 제거
      await clearAllOverlays();

      if (!mounted) return;

      // 경로 포인트 변환
      final List<latlong2.LatLng> routePoints =
          workoutDetail.trackPoints
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
            bbox: workoutDetail.bbox,
            elevations:
                workoutDetail.trackPoints
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
      }
    } catch (e) {
      debugPrint('지도 오버레이 업데이트 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return kakao.KakaoMap(
      onMapReady: (kakao.KakaoMapController controller) async {
        initializeMap(controller, colors);

        // 지도 초기화 완료 대기
        await Future<void>.delayed(const Duration(milliseconds: 50));

        if (!mounted) return;

        // 카메라 위치 조정
        await updateMapBounds(
          widget.workoutDetail.bbox,
          0.0,
          context: this.context,
        );

        // 오버레이 추가
        _updateMapOverlays(widget.workoutDetail, colors);
      },
    );
  }
}
