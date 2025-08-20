import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/thumbnail/thumbnail.dart';

class RecommendedCoursesSection extends StatelessWidget {
  const RecommendedCoursesSection({super.key, this.onMorePressed});

  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    const List<_CourseItem> courses = <_CourseItem>[
      _CourseItem(
        name: '한강 남단 코스',
        assetPath: 'assets/images/png/thumbnail_r4_3.png',
      ),
      _CourseItem(
        name: '도심 순환 코스',
        assetPath: 'assets/images/png/thumbnail_r4_3.png',
      ),
      _CourseItem(
        name: '강변 뷰 코스',
        assetPath: 'assets/images/png/thumbnail_r4_3.png',
      ),
    ];

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
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: courses.length,
            separatorBuilder:
                (BuildContext context, int _) => const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int index) {
              final _CourseItem item = courses[index];
              return SizedBox(
                width: 152,
                child: _RecommendedCourseCard(item: item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CourseItem {
  const _CourseItem({required this.name, required this.assetPath});
  final String name;
  final String assetPath;
}

class _RecommendedCourseCard extends StatelessWidget {
  const _RecommendedCourseCard({required this.item});
  final _CourseItem item;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Thumbnail(
          path: item.assetPath,
          ratio: ThumbnailRatio.r4_3,
          sourceType: ThumbnailSourceType.asset,
          hasRadius: true,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 8),
        Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body2.normalBold.copyWith(
            color: colors.labelStrong,
          ),
        ),
      ],
    );
  }
}
