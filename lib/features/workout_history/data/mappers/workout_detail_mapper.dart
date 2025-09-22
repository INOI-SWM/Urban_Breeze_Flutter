import 'package:urban_breeze/features/workout_history/data/models/workout_detail_response_model.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/activity_image.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/track_point.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_user.dart';
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
      id: model.id,
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
      user: toWorkoutUserEntity(model.user),
      thumbnailImageUrl: model.thumbnailImageUrl,
      activityImages:
          (() {
            final List<ActivityImage> images =
                model.activityImages.map(toActivityImageEntity).toList();
            images.sort(
              (ActivityImage a, ActivityImage b) =>
                  a.displayOrder.compareTo(b.displayOrder),
            );
            return images;
          })(),
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
