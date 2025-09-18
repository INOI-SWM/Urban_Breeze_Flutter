import 'workout_activity.dart';

class WorkoutList {
  factory WorkoutList.empty() {
    return const WorkoutList(
      activities: <WorkoutActivity>[],
      currentPage: 0,
      totalPages: 0,
      totalElements: 0,
      size: 0,
      hasNext: false,
      hasPrevious: false,
    );
  }

  const WorkoutList({
    required this.activities,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.hasNext,
    required this.hasPrevious,
  });

  final List<WorkoutActivity> activities;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final int size;
  final bool hasNext;
  final bool hasPrevious;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutList &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.totalElements == totalElements;
  }

  @override
  int get hashCode {
    return Object.hash(currentPage, totalPages, totalElements);
  }

  @override
  String toString() {
    return 'WorkoutList(activities: ${activities.length}, currentPage: $currentPage, totalPages: $totalPages)';
  }
}
