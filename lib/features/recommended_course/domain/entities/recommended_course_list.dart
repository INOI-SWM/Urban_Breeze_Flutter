import 'package:ridingmate/features/recommended_course/domain/entities/recommended_course.dart';

class RecommendedCourseList {
  const RecommendedCourseList({
    required this.courses,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.hasNext,
    required this.hasPrevious,
  });

  final List<RecommendedCourse> courses;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final int size;
  final bool hasNext;
  final bool hasPrevious;

  bool get isEmpty => courses.isEmpty;
  bool get isNotEmpty => courses.isNotEmpty;
  int get length => courses.length;
}
