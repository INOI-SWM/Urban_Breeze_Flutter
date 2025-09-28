import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course.dart';

class RecommendedCourseList {
  factory RecommendedCourseList.empty() {
    return const RecommendedCourseList(
      courses: <RecommendedCourse>[],
      currentPage: 0,
      totalPages: 0,
      totalElements: 0,
      size: 0,
      hasNext: false,
      hasPrevious: false,
      maxDistance: 0,
      maxElevationGain: 0,
      minDistance: 0,
      minElevationGain: 0,
    );
  }

  const RecommendedCourseList({
    required this.courses,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.hasNext,
    required this.hasPrevious,
    required this.maxDistance,
    required this.maxElevationGain,
    required this.minDistance,
    required this.minElevationGain,
  });

  final List<RecommendedCourse> courses;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final int size;
  final bool hasNext;
  final bool hasPrevious;
  final double maxDistance;
  final double maxElevationGain;
  final double minDistance;
  final double minElevationGain;

  bool get isEmpty => courses.isEmpty;
  bool get isNotEmpty => courses.isNotEmpty;
  int get length => courses.length;
}
