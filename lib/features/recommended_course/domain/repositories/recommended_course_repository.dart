import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_filter.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_list.dart';

abstract class RecommendedCourseRepository {
  Future<RecommendedCourseList> getRecommendedCourseList(
    RecommendedCourseFilter filter,
  );
}
