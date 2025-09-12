import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/my_route/application/usecases/get_my_route_detail_usecase.dart';
import 'package:urban_breeze/features/my_route/di/my_route_providers.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_detail.dart';
import 'package:urban_breeze/features/route_planning/domain/services/polyline_convert_service.dart';
import 'package:urban_breeze/features/route_sharing/application/facades/route_sharing_facade.dart';
import 'package:urban_breeze/features/route_sharing/di/route_sharing_providers.dart';
import 'package:urban_breeze/shared/chart/common_line_chart_widget.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/card/user_info_in_card.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_items_row.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:urban_breeze/shared/layout/map_with_bottom_sheet_layout.dart';
import 'package:urban_breeze/shared/map/map_constants.dart';
import 'package:urban_breeze/shared/utils/date_formatter.dart';
import 'package:urban_breeze/shared/utils/platform_action_sheet.dart';

class MyRouteDetailScreen extends ConsumerStatefulWidget {
  const MyRouteDetailScreen({super.key, required this.routeId});

  final String routeId;

  @override
  ConsumerState<MyRouteDetailScreen> createState() =>
      _MyRouteDetailScreenState();
}

class _MyRouteDetailScreenState extends ConsumerState<MyRouteDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView('my_route_detail_screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final RouteSharingFacade routeSharingFacade = ref.read(
      routeSharingFacadeProvider,
    );

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      body: FutureBuilder<MyRouteDetail>(
        future: _loadRouteDetail(),
        builder: (BuildContext context, AsyncSnapshot<MyRouteDetail> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppLoadingIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('데이터가 없습니다'));
          }

          final MyRouteDetail routeDetail = snapshot.data!;

          return MapWithBottomSheetLayout(
            showOptionButton: true,
            mapOverlays: _buildMapOverlays(routeDetail, colors),
            initialCameraFit: _calculateCameraFit(routeDetail),
            onDownloadButtonTap: (BuildContext context) {
              AmplitudeAnalytics.logButtonClick('my_route_download');
            },
            onShareButtonTap: (BuildContext context) {
              AmplitudeAnalytics.logButtonClick('my_route_share');

              showPlatformActionSheet(
                context,
                title: '공유 방식',
                options: <PlatformActionSheetOption>[
                  PlatformActionSheetOption(
                    title: '링크로 공유',
                    onSelected: () {
                      AmplitudeAnalytics.logEvent(
                        'my_route_share_link',
                        properties: <String, dynamic>{
                          'route_id': widget.routeId,
                        },
                      );
                      routeSharingFacade.shareLink(context, widget.routeId);
                    },
                  ),
                  PlatformActionSheetOption(
                    title: 'GPX 파일로 공유',
                    onSelected: () {
                      AmplitudeAnalytics.logEvent(
                        'my_route_share_gpx',
                        properties: <String, dynamic>{
                          'route_id': widget.routeId,
                        },
                      );
                      //TODO : 추후 실제 API 요청 로직으로 변경
                      routeSharingFacade.shareGpxFromAsset(
                        context,
                        'assets/gpx/sample.gpx',
                      );
                    },
                  ),
                ],
              );
            },
            onOptionButtonTap: (BuildContext context) {
              AmplitudeAnalytics.logButtonClick('my_route_options');
            },
            sheetChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UserInfoInCard(
                    userName: routeDetail.nickname,
                    userProfileImage: routeDetail.profileImageUrl,
                  ),
                  Text(
                    routeDetail.title,
                    style: AppTextStyles.heading2.bold.copyWith(
                      color: colors.labelStrong,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatKorean(routeDetail.createdAt),
                    style: AppTextStyles.label2.medium.copyWith(
                      color: colors.labelAlternative,
                    ),
                  ),
                  const SizedBox(height: 17),
                  InfoItemsRow(
                    items: <InfoItemData>[
                      InfoItemData(
                        label: '거리',
                        value:
                            '${(routeDetail.distance / 1000).toStringAsFixed(2)} km',
                      ),
                      InfoItemData(
                        label: '예상 소요 시간',
                        value: _formatDuration(routeDetail.duration),
                      ),
                      InfoItemData(
                        label: '상승 고도',
                        value:
                            '${routeDetail.elevationGain.toStringAsFixed(0)} m',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CommonLineChartWidget(
                    title: '고도',
                    spots: _extractElevationData(routeDetail.trackPoints),
                    unit: 'm',
                    color: colors.primaryNormal.withValues(alpha: 0.8),
                    emptyMessage: '고도 데이터가 없습니다',
                    height: 250,
                    showTooltip: true,
                    barWidth: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<MyRouteDetail> _loadRouteDetail() async {
    final GetMyRouteDetailUseCase useCase = ref.read(
      getMyRouteDetailUseCaseProvider,
    );
    return await useCase(widget.routeId);
  }

  String _formatDuration(int minutes) {
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '$hours시간 $remainingMinutes분';
    } else {
      return '$remainingMinutes분';
    }
  }

  /// 지도에 표시할 오버레이들을 생성
  List<Widget> _buildMapOverlays(
    MyRouteDetail routeDetail,
    SemanticColors colors,
  ) {
    final List<Widget> overlays = <Widget>[];

    // Polyline 디코딩 및 표시
    if (routeDetail.polyline.isNotEmpty) {
      final List<LatLng> routePoints = PolylineConvertService.decodeToPoints(
        routeDetail.polyline,
      );

      if (routePoints.isNotEmpty) {
        // PolylineLayer 추가 - WorkoutDetailMapWidget 패턴 사용
        overlays.add(
          PolylineLayer<LatLng>(
            polylines: <Polyline<LatLng>>[
              Polyline<LatLng>(
                points: routePoints,
                color: colors.primaryNormal,
                strokeWidth: MapConstants.polylineStrokeWidth,
              ),
            ],
          ),
        );

        // 시작점과 끝점 마커 추가 - WorkoutDetailMapWidget 패턴 사용
        overlays.add(
          MarkerLayer(
            markers: <Marker>[
              _createStartMarker(routePoints.first, colors),
              if (routePoints.length > 1)
                _createEndMarker(routePoints.last, colors),
            ],
          ),
        );
      }
    }

    return overlays;
  }

  /// 시작점 마커 생성
  Marker _createStartMarker(LatLng point, SemanticColors colors) {
    return Marker(
      point: point,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: colors.statusPositive,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  /// 끝점 마커 생성
  Marker _createEndMarker(LatLng point, SemanticColors colors) {
    return Marker(
      point: point,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: colors.statusNegative,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  /// Polyline에 맞춰 카메라 위치를 계산
  CameraFit? _calculateCameraFit(MyRouteDetail routeDetail) {
    if (routeDetail.polyline.isEmpty) {
      return null;
    }

    final List<LatLng> routePoints = PolylineConvertService.decodeToPoints(
      routeDetail.polyline,
    );

    if (routePoints.isEmpty) {
      return null;
    }

    final LatLngBounds bounds = _calculateLatLngBounds(routePoints);
    return CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(20));
  }

  /// LatLng 포인트들로부터 경계를 계산 //todo: 추후 서버 bbox를 통해 변경
  LatLngBounds _calculateLatLngBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(
        const LatLng(37.5665, 126.9780), // 서울시청 기본값
        const LatLng(37.5665, 126.9780),
      );
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final LatLng point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }

  /// TrackPoints에서 고도 데이터 추출
  List<FlSpot> _extractElevationData(List<TrackPoint> trackPoints) {
    final List<FlSpot> spots = <FlSpot>[];

    for (int i = 0; i < trackPoints.length; i++) {
      final TrackPoint point = trackPoints[i];
      spots.add(FlSpot(i.toDouble(), point.elevation));
    }

    return spots;
  }
}
