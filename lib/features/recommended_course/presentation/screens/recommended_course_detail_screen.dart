import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/route_sharing/application/facades/route_sharing_facade.dart';
import 'package:urban_breeze/features/route_sharing/di/route_sharing_providers.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/badge/content_badge.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_items_row.dart';
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
        sheetChild: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ContentBadge(
                    text: '대회코스',
                    size: ContentBadgeSize.xsmall,
                    type: ContentBadgeType.solid,
                    backgroundColor: colors.fillNormal,
                    textColor: colors.labelAlternative,
                  ),
                  const SizedBox(width: 4),
                  ContentBadge(
                    text: '쉬움',
                    size: ContentBadgeSize.xsmall,
                    type: ContentBadgeType.solid,
                    backgroundColor: colors.fillNormal,
                    textColor: colors.labelAlternative,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '서울특별시',
                style: AppTextStyles.label2.medium.copyWith(
                  color: colors.labelAlternative,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '테스트 타이틀',
                style: AppTextStyles.heading2.bold.copyWith(
                  color: colors.labelStrong,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '2019년 홍천 그란폰도 공식 경로',
                style: AppTextStyles.label1.normalBold.copyWith(
                  color: colors.labelNeutral,
                ),
              ),
              const SizedBox(height: 17),
              const InfoItemsRow(
                items: <InfoItemData>[
                  InfoItemData(label: '거리', value: '128.4 km'),
                  InfoItemData(label: '운동 시간', value: '6시간 23분'),
                  InfoItemData(label: '상승 고도', value: '920 m'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
