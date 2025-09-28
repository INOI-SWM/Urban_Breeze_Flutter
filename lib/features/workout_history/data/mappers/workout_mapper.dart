import 'package:urban_breeze/features/workout_history/data/models/workout_list_response_model.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_activity.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_list.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class WorkoutMapper {
  static WorkoutActivity toEntity(WorkoutActivityModel model) {
    return WorkoutActivity(
      activityId: model.activityId,
      title: model.title,
      startedAt: model.startedAt,
      endedAt: model.endedAt,
      distance: model.distance,
      duration: model.duration,
      elevationGain: model.elevationGain,
      thumbnailImageUrl: model.thumbnailImageUrl,
      userProfileImageUrl: model.userProfileImageUrl,
      userNickname: model.userNickname,
    );
  }

  static WorkoutList toWorkoutListEntity(WorkoutListResponseModel model) {
    return WorkoutList(
      activities: model.activities.map(toEntity).toList(),
      currentPage: model.pagination.currentPage,
      totalPages: model.pagination.totalPages,
      totalElements: model.pagination.totalElements,
      size: model.pagination.size,
      hasNext: model.pagination.hasNext,
      hasPrevious: model.pagination.hasPrevious,
    );
  }

  static WorkoutList fromApiResponse(
    ApiResponseModel<WorkoutListResponseModel> response,
  ) {
    return toWorkoutListEntity(response.data);
  }
}
