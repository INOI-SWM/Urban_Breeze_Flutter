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
import 'package:urban_breeze/shared/design_system/widgets/modal/modal_show.dart';
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
  final MapController _mapController = MapController();
  final bool _hasUserDraggedMap = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView('my_route_detail_screen');
    });
  }

  void _updateMapBounds(double bottomSheetSize, MyRouteDetail routeDetail) {
    if (_hasUserDraggedMap) return;

    final List<double> bbox = routeDetail.bbox;
    final LatLngBounds bounds = _calculateAdjustedBounds(bbox, bottomSheetSize);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 30),
      ),
    );
  }

  LatLngBounds _calculateAdjustedBounds(
    List<double> bbox,
    double bottomSheetSize,
  ) {
    final double minLng = bbox[0];
    final double minLat = bbox[1];
    final double maxLng = bbox[2];
    final double maxLat = bbox[3];

    final double latDiff = maxLat - minLat;
    final double expansionFactor = bottomSheetSize * 2.4;
    final double adjustedMinLat = minLat - (latDiff * expansionFactor);

    return LatLngBounds(LatLng(adjustedMinLat, minLng), LatLng(maxLat, maxLng));
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final RouteSharingFacade routeSharingFacade = ref.read(
      routeSharingFacadeProvider,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
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
            mapController: _mapController,
            onSizeChanged: (double size) {
              _updateMapBounds(size, routeDetail);
            },
            onDownloadButtonTap: (BuildContext context) {
              AmplitudeAnalytics.logButtonClick('my_route_download');

              showPlatformActionSheet(
                context,
                title: '다운로드 방식',
                options: <PlatformActionSheetOption>[
                  PlatformActionSheetOption(
                    title: 'GPX로 다운로드',
                    onSelected: () {
                      AmplitudeAnalytics.logEvent(
                        'my_route_download_gpx',
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

              showPlatformActionSheet(
                context,
                title: '옵션',
                options: <PlatformActionSheetOption>[
                  PlatformActionSheetOption(
                    title: '경로 삭제',
                    onSelected: () {
                      AmplitudeAnalytics.logEvent(
                        'my_route_delete',
                        properties: <String, dynamic>{
                          'route_id': widget.routeId,
                        },
                      );
                      //TODO : 추후 실제 삭제 API 요청 로직으로 변경
                      _showDeleteConfirmDialog(context);
                    },
                  ),
                ],
              );
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
                        value: _formatDuration(routeDetail.durationMinutes),
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

  /// bbox를 사용하여 카메라 위치를 계산 (초기 로드 시 기본 크기로 조정)
  CameraFit _calculateCameraFit(MyRouteDetail routeDetail) {
    final List<double> bbox = routeDetail.bbox;
    final LatLngBounds bounds = _calculateAdjustedBounds(
      bbox,
      0.5,
    ); // 초기 크기 0.5로 설정
    return CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 30),
    );
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

  /// 경로 삭제 확인 다이얼로그 표시
  void _showDeleteConfirmDialog(BuildContext context) {
    ModalShow.show(
      context: context,
      title: '경로 삭제',
      content: Text(
        '정말 경로를 삭제하시겠습니까?',
        style: AppTextStyles.body1.normalRegular.copyWith(
          color: context.semanticColor.labelNormal,
        ),
      ),
      primaryButtonText: '삭제',
      secondaryButtonText: '취소',
      onPrimaryButtonPressed: () => _deleteRoute(),
      onSecondaryButtonPressed: () {},
    );
  }

  /// 경로 삭제 실행
  void _deleteRoute() {
    //TODO : 실제 삭제 API 호출 로직 구현
    // 성공 시 이전 화면으로 돌아가기
    Navigator.of(context).pop();
  }
}
