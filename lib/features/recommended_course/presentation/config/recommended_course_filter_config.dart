import 'package:urban_breeze/features/recommended_course/domain/constants/recommended_course_constants.dart';
import 'package:urban_breeze/shared/filter/models/filter_config.dart';
import 'package:urban_breeze/shared/filter/models/filter_item.dart';

class RecommendedCourseFilterConfig implements FilterConfig {
  @override
  List<FilterItem> get filters => <FilterItem>[
    FilterItem.selection(
      id: 'recommendationType',
      title: '코스 종류',
      options: RecommendedCourseConstants.recommendationTypeFilterOptions,
    ),
    FilterItem.selection(
      id: 'region',
      title: '지역',
      options: RecommendedCourseConstants.regionFilterOptions,
    ),
    FilterItem.range(
      id: 'elevation',
      title: '상승 고도',
      range: RecommendedCourseConstants.defaultElevationRange,
      unit: 'm',
    ),
    FilterItem.range(
      id: 'distance',
      title: '거리',
      range: RecommendedCourseConstants.defaultDistanceRange,
      unit: 'km',
    ),
    FilterItem.selection(
      id: 'difficulty',
      title: '난이도',
      options: RecommendedCourseConstants.difficultyFilterOptions,
    ),
  ];
}
