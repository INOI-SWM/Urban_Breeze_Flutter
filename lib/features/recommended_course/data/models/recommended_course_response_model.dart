class RecommendedCourseResponseModel {
  const RecommendedCourseResponseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.distanceKm,
    required this.durationSeconds,
    required this.elevationGain,
    required this.region,
    required this.difficulty,
    required this.recommendationType,
    required this.thumbnailImagePath,
  });

  factory RecommendedCourseResponseModel.fromJson(Map<String, dynamic> json) {
    return RecommendedCourseResponseModel(
      id: (json['id'] as num).toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      durationSeconds: json['durationSeconds'] as int,
      elevationGain: (json['elevationGain'] as num).toDouble(),
      region: json['region'] as String,
      difficulty: json['difficulty'] as String,
      recommendationType: json['recommendationType'] as String,
      thumbnailImagePath: json['thumbnailImagePath'] as String,
    );
  }

  final String id;
  final String title;
  final String description;
  final double distanceKm;
  final int durationSeconds;
  final double elevationGain;
  final String region;
  final String difficulty;
  final String recommendationType;
  final String thumbnailImagePath;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': int.parse(id),
      'title': title,
      'description': description,
      'distanceKm': distanceKm,
      'durationSeconds': durationSeconds,
      'elevationGain': elevationGain,
      'region': region,
      'difficulty': difficulty,
      'recommendationType': recommendationType,
      'thumbnailImagePath': thumbnailImagePath,
    };
  }
}
