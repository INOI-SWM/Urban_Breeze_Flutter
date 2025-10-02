import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/home/domain/entities/latest_workout.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/card/card_list.dart';
import 'package:urban_breeze/shared/design_system/widgets/thumbnail/thumbnail.dart';
import 'package:urban_breeze/shared/utils/display_formatter.dart';

class LatestWorkoutCard extends StatelessWidget {
  const LatestWorkoutCard({
    super.key,
    this.workout,
    this.onMorePressed,
    this.onWorkoutTap,
  });
  final LatestWorkout? workout;
  final VoidCallback? onMorePressed;
  final VoidCallback? onWorkoutTap;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '최근 운동',
              style: AppTextStyles.heading2.bold.copyWith(
                color: colors.labelStrong,
              ),
            ),
            GestureDetector(
              onTap: onMorePressed,
              child: Text(
                '더보기',
                style: AppTextStyles.label1.normalBold.copyWith(
                  color: colors.labelAlternative,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (workout != null)
          GestureDetector(
            onTap: onWorkoutTap,
            child: CardList(
              thumbnailPath:
                  workout!.thumbnailImageUrl ??
                  'assets/images/png/thumbnail_r3_2.png',
              sourceType:
                  workout!.thumbnailImageUrl != null
                      ? ThumbnailSourceType.network
                      : ThumbnailSourceType.asset,
              title: workout!.title,
              createDate: _formatDate(workout!.startedAt),
              badges: <BadgeData>[
                BadgeData(
                  text: DisplayFormatter.formatDistance(workout!.distance),
                  icon: Icons.route,
                ),
                BadgeData(
                  text: DisplayFormatter.formatDurationFromSeconds(
                    workout!.duration,
                  ),
                  icon: Icons.access_time,
                ),
                if (workout!.elevationGain != null)
                  BadgeData(
                    text: DisplayFormatter.formatElevationGain(
                      workout!.elevationGain,
                    ),
                    icon: Icons.terrain,
                  ),
              ],
            ),
          )
        else
          const CardList(
            thumbnailPath: 'assets/images/png/thumbnail_r3_2.png',
            sourceType: ThumbnailSourceType.asset,
            title: '운동 기록이 없습니다',
            createDate: '',
            badges: <BadgeData>[],
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final int difference = now.difference(date).inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else if (difference < 7) {
      return '$difference일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
