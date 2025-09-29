import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/add_to_my_route_use_case.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/get_recommended_course_detail_use_case.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/share_recommended_course_use_case.dart';
import 'package:urban_breeze/features/recommended_course/di/recommended_course_providers.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_detail.dart';
import 'package:urban_breeze/features/route_planning/domain/services/polyline_convert_service.dart';
import 'package:urban_breeze/shared/chart/common_line_chart_widget.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/badge/content_badge.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_items_row.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:urban_breeze/shared/layout/map_with_bottom_sheet_layout.dart';
import 'package:urban_breeze/shared/map/map_constants.dart';
import 'package:urban_breeze/shared/map/map_marker_widget.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';
import 'package:urban_breeze/shared/utils/platform_action_sheet.dart';

class RecommendedCourseDetailScreen extends ConsumerStatefulWidget {
  const RecommendedCourseDetailScreen({super.key, required this.routeId});

  final String routeId;

  @override
  ConsumerState<RecommendedCourseDetailScreen> createState() =>
      _RecommendedCourseDetailScreenState();
}

class _RecommendedCourseDetailScreenState
    extends ConsumerState<RecommendedCourseDetailScreen>
    with ErrorDisplayMixin {
  final MapController _mapController = MapController();
  final bool _hasUserDraggedMap = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView('recommended_course_detail_screen');
    });
  }

  void _updateMapBounds(
    double bottomSheetSize,
    RecommendedCourseDetail courseDetail,
  ) {
    if (_hasUserDraggedMap) return;

    final List<double> bbox = courseDetail.bbox;
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

  List<Widget> _buildMapOverlays(
    RecommendedCourseDetail courseDetail,
    SemanticColors colors,
  ) {
    final List<Widget> overlays = <Widget>[];

    // Polyline 디코딩 및 표시
    if (courseDetail.polyline.isNotEmpty) {
      final List<LatLng> routePoints = PolylineConvertService.decodeToPoints(
        courseDetail.polyline,
      );

      if (routePoints.isNotEmpty) {
        // PolylineLayer 추가
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

        // 시작점과 끝점 마커 추가
        overlays.add(
          MarkerLayer(
            markers: <Marker>[
              MapMarkerWidget.createStartMarker(
                routePoints.first,
                colors.statusPositive,
                colors,
              ),
              if (routePoints.length > 1)
                MapMarkerWidget.createEndMarker(
                  routePoints.last,
                  colors.statusNegative,
                  colors,
                ),
            ],
          ),
        );
      }
    }

    return overlays;
  }

  CameraFit _calculateCameraFit(RecommendedCourseDetail courseDetail) {
    final List<double> bbox = courseDetail.bbox;
    final LatLngBounds bounds = _calculateAdjustedBounds(
      bbox,
      0.5,
    ); // 초기 크기 0.5로 설정
    return CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<RecommendedCourseDetail>(
        future: _loadCourseDetail(),
        builder: (
          BuildContext context,
          AsyncSnapshot<RecommendedCourseDetail> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppLoadingIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('데이터가 없습니다'));
          }

          final RecommendedCourseDetail courseDetail = snapshot.data!;

          return MapWithBottomSheetLayout(
            showOptionButton: false,
            mapOverlays: _buildMapOverlays(courseDetail, colors),
            initialCameraFit: _calculateCameraFit(courseDetail),
            mapController: _mapController,
            onSizeChanged: (double size) {
              _updateMapBounds(size, courseDetail);
            },
            onDownloadButtonTap: (BuildContext context) {
              AmplitudeAnalytics.logButtonClick('recommended_course_download');

              showPlatformActionSheet(
                context,
                title: '저장 방식',
                options: <PlatformActionSheetOption>[
                  PlatformActionSheetOption(
                    title: 'GPX로 다운로드',
                    onSelected: () {
                      AmplitudeAnalytics.logEvent(
                        'recommended_course_download_gpx',
                        properties: <String, dynamic>{
                          'route_id': widget.routeId,
                        },
                      );
                      _downloadGpx(context, courseDetail);
                    },
                  ),
                  PlatformActionSheetOption(
                    title: '나의 경로에 저장',
                    onSelected: () {
                      AmplitudeAnalytics.logEvent(
                        'recommended_course_save_to_my_route',
                        properties: <String, dynamic>{
                          'route_id': widget.routeId,
                        },
                      );
                      _addToMyRoute(context);
                    },
                  ),
                ],
              );
            },
            onShareButtonTap: (BuildContext context) {
              AmplitudeAnalytics.logButtonClick('recommended_course_share');
              _showShareOptions(context, courseDetail);
            },
            sheetChild: _buildBottomSheetContent(courseDetail, colors),
          );
        },
      ),
    );
  }

  Future<RecommendedCourseDetail> _loadCourseDetail() async {
    final GetRecommendedCourseDetailUseCase useCase = ref.read(
      getRecommendedCourseDetailUseCaseProvider,
    );

    final AppResult<RecommendedCourseDetail> result = await useCase.execute(
      widget.routeId,
    );

    if (result.isSuccess) {
      return result.dataOrNull!;
    } else {
      throw Exception(
        '추천 코스 상세 정보를 불러올 수 없습니다: ${result.exceptionOrNull?.message}',
      );
    }
  }

  Widget _buildBottomSheetContent(
    RecommendedCourseDetail courseDetail,
    SemanticColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 카테고리와 난이도 badge
          Wrap(
            spacing: 6,
            runSpacing: 8,
            children: <Widget>[
              ContentBadge(
                text: courseDetail.recommendationType,
                size: ContentBadgeSize.xsmall,
                type: ContentBadgeType.solid,
                backgroundColor: colors.fillNormal,
                textColor: colors.labelAlternative,
              ),
              ContentBadge(
                text: courseDetail.landscapeType,
                size: ContentBadgeSize.xsmall,
                type: ContentBadgeType.solid,
                backgroundColor: colors.fillNormal,
                textColor: colors.labelAlternative,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            courseDetail.region,
            style: AppTextStyles.label1.normalMedium.copyWith(
              color: colors.labelAlternative,
            ),
          ),
          Text(
            courseDetail.title,
            style: AppTextStyles.heading2.bold.copyWith(
              color: colors.labelStrong,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            courseDetail.description,
            style: AppTextStyles.label1.normalBold.copyWith(
              color: colors.labelNeutral,
            ),
          ),
          const SizedBox(height: 17),
          InfoItemsRow(
            items: <InfoItemData>[
              InfoItemData(
                label: '거리',
                value: '${courseDetail.distance.toStringAsFixed(2)} km',
              ),
              InfoItemData(
                label: '예상 소요 시간',
                value: _formatDuration(courseDetail.durationMinutes),
              ),
              InfoItemData(
                label: '상승 고도',
                value: '${courseDetail.elevationGain.toStringAsFixed(0)} m',
              ),
            ],
          ),
          const SizedBox(height: 20),
          CommonLineChartWidget(
            title: '고도',
            spots: _extractElevationData(courseDetail.trackPoints),
            unit: 'm',
            color: colors.primaryNormal.withValues(alpha: 0.8),
            emptyMessage: '고도 데이터가 없습니다',
            height: 250,
            showTooltip: true,
            barWidth: 1,
          ),
        ],
      ),
    );
  }

  Future<void> _addToMyRoute(BuildContext context) async {
    try {
      final AddToMyRouteUseCase addToMyRouteUseCase = ref.read(
        addToMyRouteUseCaseProvider,
      );

      final AppResult<void> result = await addToMyRouteUseCase.execute(
        widget.routeId,
      );

      if (!context.mounted) return;

      if (result.isSuccess) {
        showSuccessMessage(context, '나의 경로에 성공적으로 추가되었습니다');
      } else {
        showErrorFromAppResult(context, result as AppFailure<void>);
      }
    } catch (e) {
      if (!context.mounted) return;
      showErrorMessage(context, '나의 경로에 추가 중 오류가 발생했습니다: ${e.toString()}');
    }
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

  List<FlSpot> _extractElevationData(List<TrackPoint> trackPoints) {
    return trackPoints
        .map(
          (TrackPoint point) => FlSpot(point.index.toDouble(), point.elevation),
        )
        .toList();
  }

  /// 공유 옵션 표시
  void _showShareOptions(
    BuildContext context,
    RecommendedCourseDetail courseDetail,
  ) {
    showPlatformActionSheet(
      context,
      title: '공유 방식',
      options: <PlatformActionSheetOption>[
        PlatformActionSheetOption(
          title: '링크로 공유',
          onSelected: () {
            AmplitudeAnalytics.logEvent(
              'recommended_course_share_link',
              properties: <String, dynamic>{'course_id': widget.routeId},
            );
            _shareCourse(context, courseDetail);
          },
        ),
        PlatformActionSheetOption(
          title: 'GPX 파일로 공유',
          onSelected: () {
            AmplitudeAnalytics.logEvent(
              'recommended_course_share_gpx',
              properties: <String, dynamic>{'course_id': widget.routeId},
            );
            _shareGpx(context, courseDetail);
          },
        ),
      ],
    );
  }

  /// 추천경로 공유 (딥링크)
  Future<void> _shareCourse(
    BuildContext context,
    RecommendedCourseDetail courseDetail,
  ) async {
    final ShareRecommendedCourseUseCase shareUseCase = ref.read(
      shareRecommendedCourseUseCaseProvider,
    );

    final AppResult<void> result = await shareUseCase.shareDeepLink(
      context,
      widget.routeId,
    );

    if (result.isFailure) {
      if (!context.mounted) return;
      showErrorMessage(
        context,
        result.exceptionOrNull?.message ?? '공유에 실패했습니다',
      );
    }
  }

  /// GPX 파일 공유
  Future<void> _shareGpx(
    BuildContext context,
    RecommendedCourseDetail courseDetail,
  ) async {
    final ShareRecommendedCourseUseCase shareUseCase = ref.read(
      shareRecommendedCourseUseCaseProvider,
    );

    final AppResult<void> result = await shareUseCase.shareGpx(
      context,
      widget.routeId,
      courseDetail.title,
    );

    if (result.isFailure) {
      if (!context.mounted) return;
      showErrorMessage(
        context,
        result.exceptionOrNull?.message ?? 'GPX 공유에 실패했습니다',
      );
    }
  }

  /// GPX 파일 다운로드
  Future<void> _downloadGpx(
    BuildContext context,
    RecommendedCourseDetail courseDetail,
  ) async {
    final ShareRecommendedCourseUseCase shareUseCase = ref.read(
      shareRecommendedCourseUseCaseProvider,
    );

    final AppResult<void> result = await shareUseCase.downloadGpx(
      context,
      widget.routeId,
      courseDetail.title,
    );

    if (result.isFailure) {
      if (!context.mounted) return;
      showErrorMessage(
        context,
        result.exceptionOrNull?.message ?? 'GPX 다운로드에 실패했습니다',
      );
    }
  }
}
