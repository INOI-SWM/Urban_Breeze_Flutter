class UploadedImageModel {
  const UploadedImageModel({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
  });

  factory UploadedImageModel.fromJson(Map<String, dynamic> json) {
    return UploadedImageModel(
      id: json['id'] as int,
      imageUrl: json['imageUrl'] as String,
      displayOrder: json['displayOrder'] as int,
    );
  }

  final int id;
  final String imageUrl;
  final int displayOrder;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
    };
  }
}

class UploadWorkoutImagesResponseModel {
  const UploadWorkoutImagesResponseModel({
    required this.uploadedImages,
    required this.uploadedCount,
  });

  factory UploadWorkoutImagesResponseModel.fromJson(Map<String, dynamic> json) {
    return UploadWorkoutImagesResponseModel(
      uploadedImages:
          (json['uploadedImages'] as List<dynamic>)
              .map(
                (dynamic item) =>
                    UploadedImageModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      uploadedCount: json['uploadedCount'] as int,
    );
  }

  final List<UploadedImageModel> uploadedImages;
  final int uploadedCount;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uploadedImages':
          uploadedImages
              .map((UploadedImageModel image) => image.toJson())
              .toList(),
      'uploadedCount': uploadedCount,
    };
  }
}
