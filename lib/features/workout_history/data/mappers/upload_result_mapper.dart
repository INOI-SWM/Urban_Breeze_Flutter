import 'package:urban_breeze/features/workout_history/data/models/upload_workout_images_response_model.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/activity_image.dart';
import 'package:urban_breeze/features/workout_history/domain/services/activity_image_service.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class UploadResultMapper {
  static ActivityImage toActivityImageEntity(UploadedImageModel model) {
    return ActivityImage(
      id: model.id,
      imageUrl: model.imageUrl,
      displayOrder: model.displayOrder,
    );
  }

  static List<ActivityImage> toActivityImageList(
    UploadWorkoutImagesResponseModel model,
  ) {
    final List<ActivityImage> images =
        model.uploadedImages
            .map(
              (UploadedImageModel imageModel) =>
                  toActivityImageEntity(imageModel),
            )
            .toList();

    // 도메인 서비스를 통한 정렬 (단일 책임 원칙)
    return ActivityImageService.sortByDisplayOrder(images);
  }

  static List<ActivityImage> fromApiResponse(
    ApiResponseModel<UploadWorkoutImagesResponseModel> response,
  ) {
    final UploadWorkoutImagesResponseModel data = response.data;
    return toActivityImageList(data);
  }
}
