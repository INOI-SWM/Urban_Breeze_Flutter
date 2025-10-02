class RecommendedCoursesForHome {
  const RecommendedCoursesForHome({required this.courses});

  final List<RecommendedCourseForHome> courses;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendedCoursesForHome && other.courses == courses;
  }

  @override
  int get hashCode => courses.hashCode;

  @override
  String toString() {
    return 'RecommendedCoursesForHome(courses: $courses)';
  }
}

class RecommendedCourseForHome {
  const RecommendedCourseForHome({
    required this.id,
    required this.title,
    required this.distance,
    required this.duration,
    required this.difficulty,
    this.thumbnailImageUrl,
  });

  final String id;
  final String title;
  final double distance; // km
  final int duration; // seconds
  final String difficulty;
  final String? thumbnailImageUrl;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendedCourseForHome &&
        other.id == id &&
        other.title == title &&
        other.distance == distance &&
        other.duration == duration &&
        other.difficulty == difficulty &&
        other.thumbnailImageUrl == thumbnailImageUrl;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, distance, duration, difficulty, thumbnailImageUrl);

  @override
  String toString() {
    return 'RecommendedCourseForHome('
        'id: $id, '
        'title: $title, '
        'distance: $distance km, '
        'duration: $duration seconds, '
        'difficulty: $difficulty'
        ')';
  }
}
