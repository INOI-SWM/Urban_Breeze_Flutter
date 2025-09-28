import 'package:urban_breeze/features/my_route/data/models/pagination_model.dart';

class WorkoutActivityModel {
  const WorkoutActivityModel({
    required this.activityId,
    required this.title,
    required this.startedAt,
    required this.endedAt,
    required this.distance,
    required this.duration,
    required this.elevationGain,
    required this.thumbnailImageUrl,
    required this.userProfileImageUrl,
    required this.userNickname,
  });

  factory WorkoutActivityModel.fromJson(Map<String, dynamic> json) {
    return WorkoutActivityModel(
      activityId: json['activityId'] as String,
      title: json['title'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      distance: (json['distance'] as num).toDouble(), // km 단위
      duration: json['duration'] as int,
      elevationGain: (json['elevationGain'] as num).toDouble(),
      thumbnailImageUrl: json['thumbnailImageUrl'] as String,
      userProfileImageUrl: json['userProfileImageUrl'] as String,
      userNickname: json['userNickname'] as String,
    );
  }

  final String activityId;
  final String title;
  final DateTime startedAt;
  final DateTime endedAt;
  final double distance;
  final int duration;
  final double elevationGain;
  final String thumbnailImageUrl;
  final String userProfileImageUrl;
  final String userNickname;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'activityId': activityId,
      'title': title,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'distance': distance, // km 단위
      'duration': duration,
      'elevationGain': elevationGain,
      'thumbnailImageUrl': thumbnailImageUrl,
      'userProfileImageUrl': userProfileImageUrl,
      'userNickname': userNickname,
    };
  }
}

class WorkoutListResponseModel {
  const WorkoutListResponseModel({
    required this.activities,
    required this.pagination,
  });

  factory WorkoutListResponseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutListResponseModel(
      activities:
          (json['activities'] as List<dynamic>)
              .map(
                (dynamic item) =>
                    WorkoutActivityModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }

  final List<WorkoutActivityModel> activities;
  final PaginationModel pagination;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'activities':
          activities
              .map((WorkoutActivityModel activity) => activity.toJson())
              .toList(),
      'pagination': pagination.toJson(),
    };
  }
}
