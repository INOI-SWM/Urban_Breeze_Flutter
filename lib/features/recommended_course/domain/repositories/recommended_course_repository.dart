import 'package:ridingmate/features/recommended_course/domain/entities/recommended_course_filter.dart';
import 'package:ridingmate/features/recommended_course/domain/entities/recommended_course_list.dart';

abstract class RecommendedCourseRepository {
  Future<RecommendedCourseList> getRecommendedCourseList(
    RecommendedCourseFilter filter,
  );
}
