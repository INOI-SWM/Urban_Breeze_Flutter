import 'package:urban_breeze/features/workout_history/data/models/workout_detail_response_model.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/activity_image.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/track_point.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_user.dart';
import 'package:urban_breeze/features/workout_history/domain/services/activity_image_service.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class WorkoutDetailMapper {
  /// ActivityImageModel을 ActivityImage 엔티티로 변환
  static ActivityImage toActivityImageEntity(ActivityImageModel model) {
    return ActivityImage(
      id: model.id,
      imageUrl: model.imageUrl,
      displayOrder: model.displayOrder,
    );
  }

  /// TrackPointModel을 TrackPoint 엔티티로 변환
  static TrackPoint toTrackPointEntity(TrackPointModel model) {
    return TrackPoint(
      index: model.index,
      elevation: model.elevation,
      latitude: model.latitude,
      longitude: model.longitude,
      speed: model.speed,
      heartRate: model.heartRate,
    );
  }

  /// WorkoutUserModel을 WorkoutUser 엔티티로 변환
  static WorkoutUser toWorkoutUserEntity(WorkoutUserModel model) {
    return WorkoutUser(
      uuid: model.uuid,
      nickname: model.nickname,
      profileImageUrl: model.profileImageUrl,
    );
  }

  /// WorkoutDetailResponseModel을 WorkoutDetail 엔티티로 변환
  static WorkoutDetail toEntity(WorkoutDetailResponseModel model) {
    return WorkoutDetail(
      id: model.activityId,
      title: model.title,
      startedAt: model.startedAt,
      endedAt: model.endedAt,
      activeDurationMinutes: model.activeDurationMinutes,
      totalDurationMinutes: model.totalDurationMinutes,
      distance: model.distance,
      averageSpeed: model.averageSpeed,
      elevationGain: model.elevationGain,
      elevationLoss: model.elevationLoss,
      cadence: model.cadence,
      averageHeartRate: model.averageHeartRate,
      maxHeartRate: model.maxHeartRate,
      averagePower: model.averagePower,
      maxPower: model.maxPower,
      calories: model.calories,
      user: toWorkoutUserEntity(model.user),
      thumbnailImageUrl: model.thumbnailImageUrl,
      activityImages: ActivityImageService.sortByDisplayOrder(
        model.activityImages.map(toActivityImageEntity).toList(),
      ),
      trackPointsCount: model.trackPointsCount,
      trackPoints: model.trackPoints.map(toTrackPointEntity).toList(),
      bbox: model.bbox,
    );
  }

  /// ApiResponseModel을 WorkoutDetail 엔티티로 변환
  static WorkoutDetail fromApiResponse(
    ApiResponseModel<WorkoutDetailResponseModel> response,
  ) {
    return toEntity(response.data);
  }
}
