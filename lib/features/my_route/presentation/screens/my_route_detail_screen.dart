import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/my_route/application/usecases/delete_route_usecase.dart';
import 'package:urban_breeze/features/my_route/application/usecases/get_my_route_detail_usecase.dart';
import 'package:urban_breeze/features/my_route/application/usecases/get_route_gpx_usecase.dart';
import 'package:urban_breeze/features/my_route/application/usecases/get_route_tcx_usecase.dart';
import 'package:urban_breeze/features/my_route/di/my_route_providers.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_detail.dart';
import 'package:urban_breeze/features/my_route/presentation/widgets/waypoint_info_modal.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_segment.dart'
    as route_planning;
import 'package:urban_breeze/features/route_planning/domain/entities/waypoint.dart';
import 'package:urban_breeze/features/route_planning/domain/services/polyline_convert_service.dart';
import 'package:urban_breeze/features/route_planning/presentation/mappers/lat_lng_mapper.dart';
import 'package:urban_breeze/features/route_planning/presentation/services/kakao_map_overlay_service.dart';
import 'package:urban_breeze/features/route_sharing/application/facades/route_sharing_facade.dart';
import 'package:urban_breeze/features/route_sharing/di/route_sharing_providers.dart';
import 'package:urban_breeze/shared/chart/common_line_chart_widget.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/card/user_info_in_card.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_items_row.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:urban_breeze/shared/design_system/widgets/modal/modal_show.dart';
import 'package:urban_breeze/shared/layout/kakao_map_with_bottom_sheet_layout.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';
import 'package:urban_breeze/shared/utils/date_formatter.dart';
import 'package:urban_breeze/shared/utils/platform_action_sheet.dart';

class MyRouteDetailScreen extends ConsumerStatefulWidget {
  const MyRouteDetailScreen({super.key, required this.routeId});

  final String routeId;

  @override
  ConsumerState<MyRouteDetailScreen> createState() =>
      _MyRouteDetailScreenState();
}

class _MyRouteDetailScreenState extends ConsumerState<MyRouteDetailScreen>
    with ErrorDisplayMixin {
  kakao.KakaoMapController? _mapController;
  KakaoMapOverlayService? _mapOverlayService;
  final List<kakao.Poi> _routePois = <kakao.Poi>[];
  final List<kakao.Route> _routeRoutes = <kakao.Route>[];
  final Map<String, Waypoint> _poiIdToWaypoint = <String, Waypoint>{};
  bool _hasUserDraggedMap = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView('my_route_detail_screen');
    });
  }

  Future<void> _updateMapBounds(
    double bottomSheetSize,
    MyRouteDetail routeDetail,
  ) async {
    if (_mapController == null || _hasUserDraggedMap) return;

    final List<double> bbox = routeDetail.bbox;
    final List<latlong2.LatLng> fitPoints = <latlong2.LatLng>[
      latlong2.LatLng(bbox[1], bbox[0]), // minLat, minLng
      latlong2.LatLng(bbox[3], bbox[2]), // maxLat, maxLng
    ];

    final double latDiff = bbox[3] - bbox[1];
    final double expansionFactor = bottomSheetSize * 2.4;
    final double adjustedMinLat = bbox[1] - (latDiff * expansionFactor);
    fitPoints.add(latlong2.LatLng(adjustedMinLat, bbox[0]));

    final List<kakao.LatLng> kakaoPoints =
        fitPoints
            .map((latlong2.LatLng p) => LatLngMapper.toKakaoLatLng(p))
            .toList();

    final kakao.CameraUpdate cameraUpdate = kakao.CameraUpdate.fitMapPoints(
      kakaoPoints,
      padding: 20,
    );
    await _mapController!.moveCamera(cameraUpdate);
  }

  Future<void> _updateMapOverlays(
    MyRouteDetail routeDetail,
    SemanticColors colors,
  ) async {
    if (_mapOverlayService == null || !mounted) return;

    try {
      // 기존 오버레이 제거
      await _mapOverlayService!.removeAllPois(_routePois);
      await _mapOverlayService!.removeAllRoutes(_routeRoutes);
      _routePois.clear();
      _routeRoutes.clear();
      _poiIdToWaypoint.clear();

      if (!mounted) return;

      // Polyline 디코딩 및 표시
      if (routeDetail.polyline.isNotEmpty) {
        final List<latlong2.LatLng> routePoints =
            PolylineConvertService.decodeToPoints(routeDetail.polyline);

        if (routePoints.isNotEmpty) {
          // 폴리라인 추가
          final kakao.Route route = await _mapOverlayService!.addRouteLine(
            route_planning.RouteSegment(
              points: routePoints,
              distance: routeDetail.distance,
              duration: routeDetail.durationMinutes,
              elevationGain: routeDetail.elevationGain,
              bbox: routeDetail.bbox,
              elevations:
                  routeDetail.trackPoints
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
            _routeRoutes.add(route);
          }

          // 웨이포인트 마커 추가
          for (final TrackPoint trackPoint in routeDetail.trackPoints) {
            if (trackPoint.waypoint != null) {
              final kakao.Poi poi = await _mapOverlayService!.addWaypointMarker(
                latlong2.LatLng(trackPoint.latitude, trackPoint.longitude),
                trackPoint.index,
                trackPoint.waypoint!,
              );
              if (mounted) {
                _routePois.add(poi);
                _poiIdToWaypoint[poi.id] = trackPoint.waypoint!;
              }
            }
          }

          // 시작점 마커 추가
          final kakao.Poi startPoi = await _mapOverlayService!.addStartMarker(
            routePoints.first,
            colors.statusPositive,
          );
          if (mounted) {
            _routePois.add(startPoi);
          }

          // 끝점 마커 추가
          if (routePoints.length > 1) {
            final kakao.Poi endPoi = await _mapOverlayService!.addEndMarker(
              routePoints.last,
              colors.statusNegative,
            );
            if (mounted) {
              _routePois.add(endPoi);
            }
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

          return KakaoMapWithBottomSheetLayout(
            showOptionButton: true,
            onMapReady: (kakao.KakaoMapController controller) async {
              _mapController = controller;
              _mapOverlayService = KakaoMapOverlayService(
                mapController: controller,
                colors: colors,
              );

              // 지도 초기화 완료 대기
              await Future<void>.delayed(const Duration(milliseconds: 50));

              await _updateMapBounds(0.5, routeDetail);
              _updateMapOverlays(routeDetail, colors);
            },
            onSizeChanged: (double size) {
              _updateMapBounds(size, routeDetail);
            },
            onCameraMoveStart: (kakao.GestureType gestureType) {
              if (gestureType == kakao.GestureType.pan) {
                _hasUserDraggedMap = true;
              }
            },
            onPoiClick: (String poiId) {
              final Waypoint? waypoint = _poiIdToWaypoint[poiId];
              if (waypoint != null) {
                _showWaypointInfo(context, waypoint);
              }
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
                      _handleGpxDownloadOrShare(
                        context,
                        isDownload: true,
                        routeTitle: routeDetail.title,
                      );
                    },
                  ),
                  PlatformActionSheetOption(
                    title: 'TCX로 다운로드',
                    onSelected: () {
                      AmplitudeAnalytics.logEvent(
                        'my_route_download_tcx',
                        properties: <String, dynamic>{
                          'route_id': widget.routeId,
                        },
                      );
                      _handleTcxDownloadOrShare(
                        context,
                        isDownload: true,
                        routeTitle: routeDetail.title,
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
                      _handleGpxDownloadOrShare(
                        context,
                        isDownload: false,
                        routeTitle: routeDetail.title,
                      );
                    },
                  ),
                  PlatformActionSheetOption(
                    title: 'TCX 파일로 공유',
                    onSelected: () {
                      AmplitudeAnalytics.logEvent(
                        'my_route_share_tcx',
                        properties: <String, dynamic>{
                          'route_id': widget.routeId,
                        },
                      );
                      _handleTcxDownloadOrShare(
                        context,
                        isDownload: false,
                        routeTitle: routeDetail.title,
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
                        value: routeDetail.distanceDisplay,
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

  /// TrackPoints에서 고도 데이터 추출
  List<FlSpot> _extractElevationData(List<TrackPoint> trackPoints) {
    final List<FlSpot> spots = <FlSpot>[];

    for (int i = 0; i < trackPoints.length; i++) {
      final TrackPoint point = trackPoints[i];
      spots.add(FlSpot(i.toDouble(), point.elevation));
    }

    return spots;
  }

  /// GPX 다운로드 및 공유 처리
  Future<void> _handleGpxDownloadOrShare(
    BuildContext context, {
    required bool isDownload,
    String? routeTitle,
  }) async {
    final GetRouteGpxUseCase gpxUseCase = ref.read(getRouteGpxUseCaseProvider);
    final RouteSharingFacade routeSharingFacade = ref.read(
      routeSharingFacadeProvider,
    );

    try {
      final AppResult<String> result = await gpxUseCase.execute(
        routeId: widget.routeId,
      );

      if (!context.mounted) return;

      if (result.isFailure) {
        ErrorDisplay.showErrorMessage(
          context,
          result.exceptionOrNull?.message ?? 'GPX 데이터를 가져올 수 없습니다',
        );
        return;
      }

      final String gpxData = result.dataOrNull!;

      if (isDownload) {
        // 다운로드 모드: GPX 파일을 생성해서 공유
        await routeSharingFacade.shareGpxFromData(
          context,
          gpxData,
          widget.routeId,
          routeTitle: routeTitle,
        );
      } else {
        // 공유 모드: GPX 파일을 생성해서 공유
        await routeSharingFacade.shareGpxFromData(
          context,
          gpxData,
          widget.routeId,
          routeTitle: routeTitle,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ErrorDisplay.showErrorMessage(
        context,
        'GPX 처리 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  /// TCX 다운로드 및 공유 처리
  Future<void> _handleTcxDownloadOrShare(
    BuildContext context, {
    required bool isDownload,
    String? routeTitle,
  }) async {
    final GetRouteTcxUseCase tcxUseCase = ref.read(getRouteTcxUseCaseProvider);
    final RouteSharingFacade routeSharingFacade = ref.read(
      routeSharingFacadeProvider,
    );

    try {
      final AppResult<String> result = await tcxUseCase.execute(
        routeId: widget.routeId,
      );

      if (!context.mounted) return;

      if (result.isFailure) {
        ErrorDisplay.showErrorMessage(
          context,
          result.exceptionOrNull?.message ?? 'TCX 데이터를 가져올 수 없습니다',
        );
        return;
      }

      final String tcxData = result.dataOrNull!;

      if (isDownload) {
        // 다운로드 모드: TCX 파일을 생성해서 공유
        await routeSharingFacade.shareTcxFromData(
          context,
          tcxData,
          widget.routeId,
          routeTitle: routeTitle,
        );
      } else {
        // 공유 모드: TCX 파일을 생성해서 공유
        await routeSharingFacade.shareTcxFromData(
          context,
          tcxData,
          widget.routeId,
          routeTitle: routeTitle,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ErrorDisplay.showErrorMessage(
        context,
        'TCX 처리 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
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
  Future<void> _deleteRoute() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (BuildContext context) =>
                const Center(child: CircularProgressIndicator()),
      );

      final DeleteRouteUseCase deleteRouteUseCase = ref.read(
        deleteRouteUseCaseProvider,
      );

      final AppResult<void> result = await deleteRouteUseCase.execute(
        widget.routeId,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      if (result.isSuccess) {
        AmplitudeAnalytics.logEvent(
          'my_route_delete_success',
          properties: <String, dynamic>{'route_id': widget.routeId},
        );

        showSuccessMessage(context, '경로가 삭제되었습니다');

        Navigator.of(context).pop(true);
      } else {
        ErrorDisplay.showErrorMessage(
          context,
          result.exceptionOrNull?.message ?? '경로 삭제에 실패했습니다',
        );
      }
    } catch (e) {
      if (!mounted) return;

      AmplitudeAnalytics.logEvent(
        'my_route_delete_error',
        properties: <String, dynamic>{
          'route_id': widget.routeId,
          'error': e.toString(),
        },
      );

      ErrorDisplay.showErrorMessage(
        context,
        '경로 삭제 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  /// Waypoint 정보 모달 표시
  void _showWaypointInfo(BuildContext context, Waypoint waypoint) {
    AmplitudeAnalytics.logEvent(
      'my_route_waypoint_view',
      properties: <String, dynamic>{
        'waypoint_type': waypoint.type.name,
        'has_title': waypoint.title != null,
        'has_description': waypoint.description != null,
      },
    );

    WaypointInfoModal.show(context, waypoint: waypoint);
  }
}
