import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/route_sharing/application/facades/route_sharing_facade.dart';
import 'package:urban_breeze/features/route_sharing/di/route_sharing_providers.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/card/user_info_in_card.dart';
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
        showOptionButton: true,
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
        },
        sheetChild: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const UserInfoInCard(userName: 'test', userProfileImage: 'test'),
              Text(
                '테스트 타이틀',
                style: AppTextStyles.heading2.bold.copyWith(
                  color: colors.labelStrong,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '2025.07.22',
                style: AppTextStyles.label2.medium.copyWith(
                  color: colors.labelAlternative,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
