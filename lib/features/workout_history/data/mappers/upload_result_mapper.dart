import 'package:urban_breeze/features/workout_history/data/models/upload_workout_images_response_model.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/upload_result.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class UploadResultMapper {
  /// UploadedImageModel을 UploadedImage 엔터티로 변환
  static UploadedImage toUploadedImageEntity(UploadedImageModel model) {
    return UploadedImage(
      id: model.id,
      imageUrl: model.imageUrl,
      displayOrder: model.displayOrder,
    );
  }

  /// UploadWorkoutImagesResponseModel을 UploadResult 엔터티로 변환
  static UploadResult toEntity(UploadWorkoutImagesResponseModel model) {
    return UploadResult(
      uploadedImages:
          model.uploadedImages
              .map(
                (UploadedImageModel imageModel) =>
                    toUploadedImageEntity(imageModel),
              )
              .toList(),
      uploadedCount: model.uploadedCount,
    );
  }

  /// API 응답에서 UploadResult 엔터티로 변환
  static UploadResult fromApiResponse(
    ApiResponseModel<UploadWorkoutImagesResponseModel> response,
  ) {
    final UploadWorkoutImagesResponseModel data = response.data;
    return toEntity(data);
  }
}
