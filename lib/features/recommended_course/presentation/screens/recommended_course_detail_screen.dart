import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/route_sharing/application/facades/route_sharing_facade.dart';
import 'package:urban_breeze/features/route_sharing/di/route_sharing_providers.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/layout/map_with_bottom_sheet_layout.dart';
import 'package:urban_breeze/shared/utils/platform_action_sheet.dart';

class RecommendedCourseDetailScreen extends ConsumerStatefulWidget {
  const RecommendedCourseDetailScreen({super.key});

  @override
  ConsumerState<RecommendedCourseDetailScreen> createState() =>
      _RecommendedCourseDetailScreenState();
}

class _RecommendedCourseDetailScreenState
    extends ConsumerState<RecommendedCourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView('recommended_course_detail_screen');
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
        onDownloadButtonTap: (BuildContext context) {
          AmplitudeAnalytics.logButtonClick('recommended_course_download');

          showPlatformActionSheet(
            context,
            title: '저장 방식',
            options: <PlatformActionSheetOption>[
              PlatformActionSheetOption(
                title: '나의 경로에 저장',
                onSelected: () {
                  // 나의 경로에 저장 이벤트
                  AmplitudeAnalytics.logEvent(
                    'recommended_course_save_to_my_route',
                  );
                },
              ),
              PlatformActionSheetOption(
                title: 'GPX 다운로드',
                onSelected: () {
                  // GPX 다운로드 이벤트
                  AmplitudeAnalytics.logEvent(
                    'recommended_course_gpx_download',
                  );
                },
              ),
            ],
          );
        },
        onShareButtonTap: (BuildContext context) {
          AmplitudeAnalytics.logButtonClick('recommended_course_share');

          showPlatformActionSheet(
            context,
            title: '공유 방식',
            options: <PlatformActionSheetOption>[
              PlatformActionSheetOption(
                title: '링크로 공유',
                onSelected: () {
                  AmplitudeAnalytics.logEvent('recommended_course_share_link');
                  routeSharingFacade.shareLink(context, 'rec1');
                },
              ),
              PlatformActionSheetOption(
                title: 'GPX 파일로 공유',
                onSelected: () {
                  AmplitudeAnalytics.logEvent('recommended_course_share_gpx');
                  routeSharingFacade.shareGpxFromAsset(
                    context,
                    'assets/gpx/sample.gpx',
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
