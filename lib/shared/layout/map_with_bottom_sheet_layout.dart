import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/map/common_map_widgets.dart';
import 'package:urban_breeze/shared/map/map_constants.dart';

class MapWithBottomSheetLayout extends StatefulWidget {
  const MapWithBottomSheetLayout({
    super.key,
    this.mapOverlays = const <Widget>[],
    this.initialChildSize = 0.5,
    this.minChildSize = 0.2,
    this.maxChildSize = 0.8,
    this.snapSizes = const <double>[0.2, 0.5, 0.8],
    required this.sheetChild,
    this.showOptionButton = false,
    required this.onDownloadButtonTap,
    required this.onShareButtonTap,
    this.onOptionButtonTap,
    this.initialCenter,
    this.initialZoom,
    this.initialCameraFit,
  });

  final List<Widget> mapOverlays;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final List<double> snapSizes;
  final Widget sheetChild;
  final bool showOptionButton;
  final Function(BuildContext context) onDownloadButtonTap;
  final Function(BuildContext context) onShareButtonTap;
  final Function(BuildContext context)? onOptionButtonTap;
  final LatLng? initialCenter;
  final double? initialZoom;
  final CameraFit? initialCameraFit;

  @override
  State<MapWithBottomSheetLayout> createState() =>
      _MapWithBottomSheetLayoutState();
}

class _MapWithBottomSheetLayoutState extends State<MapWithBottomSheetLayout> {
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
    if (_contentKey.currentContext != null) {
      final RenderBox? renderBox =
          _contentKey.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final double contentHeight = renderBox.size.height;
        final double screenHeight = MediaQuery.of(context).size.height;

        // AppBar + 핸들 + 여백을 고려한 전체 높이 계산
        const double appBarHeight = 56.0;
        const double handleHeight = 28.0; // 핸들 + 여백
        const double padding = 40.0; // 상하 여백

        final double totalHeight =
            contentHeight + appBarHeight + handleHeight + padding;
        final double calculatedRatio = totalHeight / screenHeight;

        setState(() {
          _calculatedMaxChildSize = calculatedRatio.clamp(
            widget.minChildSize,
            0.95,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: <Widget>[
            FlutterMap(
              options: MapOptions(
                initialCenter:
                    widget.initialCenter ?? MapConstants.seoulCityHall,
                initialZoom: widget.initialZoom ?? MapConstants.defaultZoom,
                initialCameraFit: widget.initialCameraFit,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: <Widget>[
                CommonMapWidgets.createTileLayer(),
                ...widget.mapOverlays,
                CommonMapWidgets.createAttributionWidget(),
              ],
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
    return DraggableScrollableSheet(
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: _calculatedMaxChildSize,
      snap: true,
      snapSizes: <double>[
        widget.minChildSize,
        widget.initialChildSize,
        _calculatedMaxChildSize,
      ],
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
                      CustomIconButton(
                        icon: Icons.file_download_outlined,
                        onTap: () => widget.onDownloadButtonTap(context),
                      ),
                      CustomIconButton(
                        icon: Icons.share_outlined,
                        onTap: () => widget.onShareButtonTap(context),
                      ),
                      if (widget.showOptionButton)
                        CustomIconButton(
                          icon: Icons.more_horiz_outlined,
                          onTap: () => widget.onOptionButtonTap?.call(context),
                        ),
                    ],
                    enableSafeArea: false,
                    safeAreaTop: false,
                    safeAreaBottom: false,
                  ),
                  Container(key: _contentKey, child: widget.sheetChild),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
