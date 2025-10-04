class RecommendedCourseResponseModel {
  const RecommendedCourseResponseModel({
    required this.routeId,
    required this.title,
    required this.description,
    required this.distanceM,
    required this.durationMinutes,
    required this.elevationGain,
    required this.region,
    required this.difficulty,
    required this.recommendationType,
    required this.thumbnailImagePath,
  });

  factory RecommendedCourseResponseModel.fromJson(Map<String, dynamic> json) {
    return RecommendedCourseResponseModel(
      routeId: json['routeId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      distanceM: (json['distanceM'] as num).toDouble(),
      durationMinutes: json['durationSeconds'] as int,
      elevationGain: (json['elevationGain'] as num).toDouble(),
      region: json['region'] as String,
      difficulty: json['difficulty'] as String,
      recommendationType: json['recommendationType'] as String,
      thumbnailImagePath: json['thumbnailImagePath'] as String,
    );
  }

  final String routeId;
  final String title;
  final String description;
  final double distanceM;
  final int durationMinutes; // 초 단위 (API 필드명은 durationSeconds로 변경됨)
  final double elevationGain;
  final String region;
  final String difficulty;
  final String recommendationType;
  final String thumbnailImagePath;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'routeId': routeId,
      'title': title,
      'description': description,
      'distanceM': distanceM,
      'durationSeconds': durationMinutes,
      'elevationGain': elevationGain,
      'region': region,
      'difficulty': difficulty,
      'recommendationType': recommendationType,
      'thumbnailImagePath': thumbnailImagePath,
    };
  }
}
