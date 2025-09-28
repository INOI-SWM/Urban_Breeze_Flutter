import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/get_recommended_course_detail_use_case.dart';
import 'package:urban_breeze/features/recommended_course/di/recommended_course_providers.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_detail.dart';
import 'package:urban_breeze/features/route_planning/domain/services/polyline_convert_service.dart';
import 'package:urban_breeze/features/route_sharing/application/facades/route_sharing_facade.dart';
import 'package:urban_breeze/features/route_sharing/di/route_sharing_providers.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_items_row.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:urban_breeze/shared/layout/map_with_bottom_sheet_layout.dart';
import 'package:urban_breeze/shared/map/map_constants.dart';
import 'package:urban_breeze/shared/map/map_marker_widget.dart';
import 'package:urban_breeze/shared/utils/platform_action_sheet.dart';

class RecommendedCourseDetailScreen extends ConsumerStatefulWidget {
  const RecommendedCourseDetailScreen({super.key, required this.routeId});

  final String routeId;

  @override
  ConsumerState<RecommendedCourseDetailScreen> createState() =>
      _RecommendedCourseDetailScreenState();
}

class _RecommendedCourseDetailScreenState
    extends ConsumerState<RecommendedCourseDetailScreen> {
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

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final RouteSharingFacade routeSharingFacade = ref.read(
      routeSharingFacadeProvider,
    );

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
            showOptionButton: true,
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
                title: '다운로드 방식',
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
                      _downloadGpx(context, courseDetail, routeSharingFacade);
                    },
                  ),
                ],
              );
            },
            onShareButtonTap: (BuildContext context) {
              AmplitudeAnalytics.logButtonClick('recommended_course_share');
              _shareGpx(context, courseDetail, routeSharingFacade);
            },
            onOptionButtonTap: (BuildContext context) {
              AmplitudeAnalytics.logButtonClick('recommended_course_options');

              showPlatformActionSheet(
                context,
                title: '옵션',
                options: <PlatformActionSheetOption>[
                  PlatformActionSheetOption(
                    title: '나의 경로에 저장',
                    onSelected: () {
                      AmplitudeAnalytics.logEvent(
                        'recommended_course_save_to_my_route',
                        properties: <String, dynamic>{
                          'route_id': widget.routeId,
                        },
                      );
                      // TODO: 나의 경로에 저장 기능 구현
                    },
                  ),
                ],
              );
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

  /// bbox를 사용하여 카메라 위치를 계산 (초기 로드 시 기본 크기로 조정)
  CameraFit _calculateCameraFit(RecommendedCourseDetail courseDetail) {
    final List<double> bbox = courseDetail.bbox;
    final LatLngBounds bounds = _calculateAdjustedBounds(bbox, 0.5);
    return CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 30),
    );
  }

  Widget _buildBottomSheetContent(
    RecommendedCourseDetail courseDetail,
    SemanticColors colors,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 제목
            Text(
              courseDetail.title,
              style: AppTextStyles.title2.bold.copyWith(
                color: colors.labelStrong,
              ),
            ),
            const SizedBox(height: 8),

            // 추천 타입 배지
            if (courseDetail.recommendationType.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryNormal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    courseDetail.recommendationType,
                    style: AppTextStyles.caption1.medium.copyWith(
                      color: colors.primaryNormal,
                    ),
                  ),
                ),
              ),

            // 기본 정보
            InfoItemsRow(
              items: <InfoItemData>[
                InfoItemData(
                  label: '거리',
                  value: '${courseDetail.distance.toStringAsFixed(1)} km',
                ),
                InfoItemData(
                  label: '상승고도',
                  value: '${courseDetail.elevationGain.toStringAsFixed(0)}m',
                ),
                InfoItemData(
                  label: '예상시간',
                  value: '${courseDetail.estimatedDurationMinutes}분',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 설명
            if (courseDetail.description.isNotEmpty) ...<Widget>[
              Text(
                '코스 설명',
                style: AppTextStyles.title3.bold.copyWith(
                  color: colors.labelStrong,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                courseDetail.description,
                style: AppTextStyles.body1.normalRegular.copyWith(
                  color: colors.labelNormal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _downloadGpx(
    BuildContext context,
    RecommendedCourseDetail courseDetail,
    RouteSharingFacade routeSharingFacade,
  ) async {
    try {
      await routeSharingFacade.shareGpxFromData(
        context,
        courseDetail.polyline,
        widget.routeId,
        routeTitle: courseDetail.title,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GPX 다운로드 중 오류가 발생했습니다: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _shareGpx(
    BuildContext context,
    RecommendedCourseDetail courseDetail,
    RouteSharingFacade routeSharingFacade,
  ) async {
    try {
      await routeSharingFacade.shareGpxFromData(
        context,
        courseDetail.polyline,
        widget.routeId,
        routeTitle: courseDetail.title,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GPX 공유 중 오류가 발생했습니다: ${e.toString()}')),
        );
      }
    }
  }
}
