class RecommendedCourseDetailResponseModel {
  const RecommendedCourseDetailResponseModel({
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

  factory RecommendedCourseDetailResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecommendedCourseDetailResponseModel(
      courseId: json['routeId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      polyline: json['polyline'] as String,
      distance: (json['distance'] as num).toDouble(),
      elevationGain: (json['elevationGain'] as num).toDouble(),
      estimatedDurationMinutes: json['durationMinutes'] as int,
      recommendationType: json['recommendationType'] as String,
      difficulty:
          json['landscapeType'] as String, // landscapeType을 difficulty로 매핑
      region: json['region'] as String,
      thumbnailImageUrl:
          json['profileImageUrl']
              as String, // profileImageUrl을 thumbnailImageUrl로 매핑
      bbox:
          (json['bbox'] as List<dynamic>)
              .map((dynamic e) => (e as num).toDouble())
              .toList(),
    );
  }

  final String courseId;
  final String title;
  final String description;
  final String polyline;
  final double distance;
  final double elevationGain;
  final int estimatedDurationMinutes;
  final String recommendationType;
  final String difficulty;
  final String region;
  final String thumbnailImageUrl;
  final List<double> bbox;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'courseId': courseId,
      'title': title,
      'description': description,
      'polyline': polyline,
      'distance': distance,
      'elevationGain': elevationGain,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'recommendationType': recommendationType,
      'difficulty': difficulty,
      'region': region,
      'thumbnailImageUrl': thumbnailImageUrl,
      'bbox': bbox,
    };
  }
}
