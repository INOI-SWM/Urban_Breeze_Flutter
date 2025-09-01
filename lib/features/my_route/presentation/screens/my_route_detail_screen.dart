import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/my_route/application/usecases/get_my_route_detail_usecase.dart';
import 'package:urban_breeze/features/my_route/di/my_route_providers.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_detail.dart';
import 'package:urban_breeze/features/route_sharing/application/facades/route_sharing_facade.dart';
import 'package:urban_breeze/features/route_sharing/di/route_sharing_providers.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/card/user_info_in_card.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_items_row.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
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

          return MapWithBottomSheetLayout(
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
                    routeDetail.createdAt,
                    style: AppTextStyles.label2.medium.copyWith(
                      color: colors.labelAlternative,
                    ),
                  ),
                  const SizedBox(height: 17),
                  InfoItemsRow(
                    items: <InfoItemData>[
                      InfoItemData(
                        label: '거리',
                        value: '${routeDetail.distance.toStringAsFixed(1)} km',
                      ),
                      InfoItemData(
                        label: '운동 시간',
                        value: _formatDuration(routeDetail.duration),
                      ),
                      InfoItemData(
                        label: '상승 고도',
                        value:
                            '${routeDetail.elevationGain.toStringAsFixed(0)} m',
                      ),
                    ],
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
}
