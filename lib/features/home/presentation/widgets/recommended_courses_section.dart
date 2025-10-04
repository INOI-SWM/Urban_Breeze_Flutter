import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/home/domain/entities/recommended_courses_for_home.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/thumbnail/thumbnail.dart';
import 'package:urban_breeze/shared/utils/display_formatter.dart';

class RecommendedCoursesSection extends StatelessWidget {
  const RecommendedCoursesSection({
    super.key,
    this.courses,
    this.onMorePressed,
    this.onCourseTap,
  });

  final RecommendedCoursesForHome? courses;
  final VoidCallback? onMorePressed;
  final Function(String courseId)? onCourseTap;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final List<RecommendedCourseForHome> courseList =
        courses?.courses ?? <RecommendedCourseForHome>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '추천 코스',
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
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child:
              courseList.isEmpty
                  ? const Center(child: Text('추천 코스가 없습니다'))
                  : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: courseList.length,
                    separatorBuilder:
                        (BuildContext context, int _) =>
                            const SizedBox(width: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final RecommendedCourseForHome course = courseList[index];
                      return SizedBox(
                        width: 152,
                        child: _RecommendedCourseCard(
                          course: course,
                          onTap: () => onCourseTap?.call(course.id),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

class _RecommendedCourseCard extends StatelessWidget {
  const _RecommendedCourseCard({required this.course, this.onTap});
  final RecommendedCourseForHome course;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Thumbnail(
            path:
                course.thumbnailImageUrl ??
                'assets/images/png/thumbnail_r4_3.png',
            ratio: ThumbnailRatio.r4_3,
            sourceType:
                course.thumbnailImageUrl != null
                    ? ThumbnailSourceType.network
                    : ThumbnailSourceType.asset,
            hasRadius: true,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Text(
            course.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body2.normalBold.copyWith(
              color: colors.labelStrong,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              Text(
                DisplayFormatter.formatDistanceFromMeters(course.distance),
                style: AppTextStyles.caption1.regular.copyWith(
                  color: colors.labelAlternative,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DisplayFormatter.formatDurationFromSeconds(course.duration),
                style: AppTextStyles.caption1.regular.copyWith(
                  color: colors.labelAlternative,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
