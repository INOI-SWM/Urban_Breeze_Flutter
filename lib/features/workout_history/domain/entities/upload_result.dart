class UploadedImage {
  const UploadedImage({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
  });

  final int id;
  final String imageUrl;
  final int displayOrder;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UploadedImage &&
        other.id == id &&
        other.imageUrl == imageUrl &&
        other.displayOrder == displayOrder;
  }

  @override
  int get hashCode => Object.hash(id, imageUrl, displayOrder);

  @override
  String toString() {
    return 'UploadedImage(id: $id, imageUrl: $imageUrl, displayOrder: $displayOrder)';
  }
}

class UploadResult {
  const UploadResult({
    required this.uploadedImages,
    required this.uploadedCount,
  });

  final List<UploadedImage> uploadedImages;
  final int uploadedCount;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UploadResult &&
        other.uploadedCount == uploadedCount &&
        other.uploadedImages.length == uploadedImages.length;
  }

  @override
  int get hashCode => Object.hash(uploadedImages, uploadedCount);

  @override
  String toString() {
    return 'UploadResult(uploadedCount: $uploadedCount, uploadedImages: ${uploadedImages.length})';
  }
}
