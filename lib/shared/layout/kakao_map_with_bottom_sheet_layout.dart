import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/route_planning/presentation/mappers/lat_lng_mapper.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/layout/bottom_sheet_size_calculator.dart';
import 'package:urban_breeze/shared/map/map_constants.dart';

class KakaoMapWithBottomSheetLayout extends StatefulWidget {
  const KakaoMapWithBottomSheetLayout({
    super.key,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.2,
    this.maxChildSize = 0.8,
    this.snapSizes = const <double>[0.2, 0.5, 0.8],
    required this.sheetChild,
    this.showOptionButton = false,
    this.onDownloadButtonTap,
    this.onShareButtonTap,
    this.onOptionButtonTap,
    this.initialZoom,
    this.initialCameraPosition,
    this.onMapReady,
    this.onSizeChanged,
    this.onPoiClick,
    this.onCameraMoveStart,
  });

  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final List<double> snapSizes;
  final Widget sheetChild;
  final bool showOptionButton;
  final Function(BuildContext context)? onDownloadButtonTap;
  final Function(BuildContext context)? onShareButtonTap;
  final Function(BuildContext context)? onOptionButtonTap;
  final double? initialZoom;
  final kakao.CameraPosition? initialCameraPosition;
  final Function(kakao.KakaoMapController)? onMapReady;
  final ValueChanged<double>? onSizeChanged;
  final Function(String poiId)? onPoiClick;
  final Function(kakao.GestureType)? onCameraMoveStart;

  @override
  State<KakaoMapWithBottomSheetLayout> createState() =>
      _KakaoMapWithBottomSheetLayoutState();
}

class _KakaoMapWithBottomSheetLayoutState
    extends State<KakaoMapWithBottomSheetLayout> {
  double _calculatedMaxChildSize = 0.8;
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateMaxChildSize();
    });
  }

  void _calculateMaxChildSize() {
    setState(() {
      _calculatedMaxChildSize = BottomSheetSizeCalculator.calculateMaxChildSize(
        _contentKey,
        context,
        widget.initialChildSize,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: <Widget>[
            kakao.KakaoMap(
              option: kakao.KakaoMapOption(
                position:
                    widget.initialCameraPosition != null
                        ? widget.initialCameraPosition!.position
                        : LatLngMapper.toKakaoLatLng(
                          MapConstants.seoulCityHall,
                        ),
                zoomLevel:
                    widget.initialCameraPosition != null
                        ? widget.initialCameraPosition!.zoomLevel
                        : widget.initialZoom != null
                        ? widget.initialZoom!.toInt()
                        : MapConstants.defaultZoom.toInt(),
                mapType: kakao.MapType.normal,
              ),
              onMapReady: (kakao.KakaoMapController controller) {
                widget.onMapReady?.call(controller);
              },
              onPoiClick:
                  widget.onPoiClick != null
                      ? (
                        kakao.LabelController labelController,
                        kakao.Poi poi,
                      ) => widget.onPoiClick!(poi.id)
                      : null,
              onCameraMoveStart:
                  widget.onCameraMoveStart != null
                      ? (kakao.GestureType gestureType) {
                        try {
                          widget.onCameraMoveStart!(gestureType);
                        } catch (e) {
                          debugPrint('onCameraMoveStart 에러: $e');
                        }
                      }
                      : null,
            ),
            _buildDraggableSheet(context, colors, constraints),
          ],
        );
      },
    );
  }

  Widget _buildDraggableSheet(
    BuildContext context,
    SemanticColors colors,
    BoxConstraints constraints,
  ) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (DraggableScrollableNotification notification) {
        widget.onSizeChanged?.call(notification.extent);
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: widget.initialChildSize,
        minChildSize: widget.minChildSize,
        maxChildSize: _calculatedMaxChildSize,
        snap: true,
        snapSizes: () {
          final Set<double> uniqueSizes = <double>{
            widget.minChildSize,
            widget.initialChildSize,
            _calculatedMaxChildSize,
          };
          final List<double> sortedSizes = uniqueSizes.toList()..sort();
          return sortedSizes;
        }(),
        builder: (BuildContext context, ScrollController scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: colors.backgroundNormalNormal,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
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
                      CustomAppBar(
                        leading: CustomIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        actions: <Widget>[
                          if (widget.onDownloadButtonTap != null)
                            CustomIconButton(
                              icon: Icons.file_download_outlined,
                              onTap:
                                  () =>
                                      widget.onDownloadButtonTap?.call(context),
                            ),
                          if (widget.onShareButtonTap != null)
                            CustomIconButton(
                              icon: Icons.share_outlined,
                              onTap:
                                  () => widget.onShareButtonTap?.call(context),
                            ),
                          if (widget.showOptionButton)
                            CustomIconButton(
                              icon: Icons.more_horiz_outlined,
                              onTap:
                                  () => widget.onOptionButtonTap?.call(context),
                            ),
                        ],
                        enableSafeArea: false,
                        safeAreaTop: false,
                        safeAreaBottom: false,
                      ),
                      Container(key: _contentKey, child: widget.sheetChild),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
