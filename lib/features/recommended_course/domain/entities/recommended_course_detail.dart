class RecommendedCourseDetail {
  const RecommendedCourseDetail({
    required this.courseId,
    required this.title,
    required this.description,
    required this.polyline,
    required this.distance,
    required this.elevationGain,
    required this.estimatedDurationMinutes,
    required this.recommendationType,
    required this.difficulty,
    required this.region,
    required this.thumbnailImageUrl,
    required this.bbox,
  });

  final String courseId;
  final String title;
  final String description;
  final String polyline;
  final double distance; // km
  final double elevationGain; // m
  final int estimatedDurationMinutes; // 분
  final String recommendationType;
  final String difficulty;
  final String region;
  final String thumbnailImageUrl;
  final List<double> bbox; // [minLng, minLat, maxLng, maxLat]
}
