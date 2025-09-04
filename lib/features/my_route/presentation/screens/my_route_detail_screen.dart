import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/route_sharing/application/facades/route_sharing_facade.dart';
import 'package:urban_breeze/features/route_sharing/di/route_sharing_providers.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/layout/map_with_bottom_sheet_layout.dart';
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
      body: MapWithBottomSheetLayout(
        sheetChild: const SizedBox(height: 240),
        showOptionButton: true,
        onDownloadButtonTap: (BuildContext context) {
          AmplitudeAnalytics.logButtonClick('my_route_download');
          showPlatformActionSheet(
            context,
            title: '저장 방식',
            options: <PlatformActionSheetOption>[
              PlatformActionSheetOption(
                title: 'GPX 다운로드',
                onSelected: () {
                  AmplitudeAnalytics.logEvent(
                    'my_route_download_gpx',
                    properties: <String, dynamic>{'route_id': widget.routeId},
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
                    properties: <String, dynamic>{'route_id': widget.routeId},
                  );
                  routeSharingFacade.shareLink(context, widget.routeId);
                },
              ),
              PlatformActionSheetOption(
                title: 'GPX 파일로 공유',
                onSelected: () {
                  AmplitudeAnalytics.logEvent(
                    'my_route_share_gpx',
                    properties: <String, dynamic>{'route_id': widget.routeId},
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
                title: '삭제',
                onSelected: () {
                  AmplitudeAnalytics.logEvent(
                    'my_route_delete',
                    properties: <String, dynamic>{'route_id': widget.routeId},
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
