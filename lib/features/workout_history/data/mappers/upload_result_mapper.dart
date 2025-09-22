import 'package:urban_breeze/features/workout_history/data/models/upload_workout_images_response_model.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/activity_image.dart';
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
    return model.uploadedImages
        .map(
          (UploadedImageModel imageModel) => toActivityImageEntity(imageModel),
        )
        .toList();
  }

  static List<ActivityImage> fromApiResponse(
    ApiResponseModel<UploadWorkoutImagesResponseModel> response,
  ) {
    final UploadWorkoutImagesResponseModel data = response.data;
    return toActivityImageList(data);
  }
}
