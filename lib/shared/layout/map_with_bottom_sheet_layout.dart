import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:ridingmate/shared/map/common_map_widgets.dart';
import 'package:ridingmate/shared/map/map_constants.dart';

class MapWithBottomSheetLayout extends StatelessWidget {
  const MapWithBottomSheetLayout({
    super.key,
    this.mapOverlays = const <Widget>[],
    this.initialChildSize = 0.35,
    this.minChildSize = 0.2,
    this.maxChildSize = 0.8,
    this.snapSizes = const <double>[0.35, 0.6, 0.8],
    required this.sheetChild,
    this.showOptionButton = false,
  });

  final List<Widget> mapOverlays;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final List<double> snapSizes;
  final Widget sheetChild;
  final bool showOptionButton;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return Stack(
      children: <Widget>[
        FlutterMap(
          options: const MapOptions(
            initialCenter: MapConstants.seoulCityHall,
            initialZoom: MapConstants.defaultZoom,
            interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: <Widget>[
            CommonMapWidgets.createTileLayer(),
            ...mapOverlays,
          ],
        ),
        DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          snap: true,
          snapSizes: snapSizes,
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
                            onTap: () {},
                          ),
                          CustomIconButton(
                            icon: Icons.share_outlined,
                            onTap: () {},
                          ),
                          if (showOptionButton)
                            CustomIconButton(
                              icon: Icons.more_horiz_outlined,
                              onTap: () {},
                            ),
                        ],
                        enableSafeArea: false,
                        safeAreaTop: false,
                        safeAreaBottom: false,
                      ),
                      sheetChild,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
