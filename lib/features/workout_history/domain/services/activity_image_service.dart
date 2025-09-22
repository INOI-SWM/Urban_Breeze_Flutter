import 'package:urban_breeze/features/workout_history/domain/entities/activity_image.dart';

/// ActivityImage 관련 도메인 서비스
/// 정렬, 필터링 등의 비즈니스 로직을 담당
class ActivityImageService {
  /// displayOrder로 이미지 리스트 정렬 (오름차순)
  static List<ActivityImage> sortByDisplayOrder(List<ActivityImage> images) {
    final List<ActivityImage> sortedImages = List<ActivityImage>.from(images);
    sortedImages.sort(
      (ActivityImage a, ActivityImage b) =>
          a.displayOrder.compareTo(b.displayOrder),
    );
    return sortedImages;
  }

  /// 썸네일(displayOrder: 0) 제외 필터링
  static List<ActivityImage> excludeThumbnails(List<ActivityImage> images) {
    return images
        .where((ActivityImage image) => image.displayOrder != 0)
        .toList();
  }

  /// 썸네일 제외 + 정렬
  static List<ActivityImage> getDisplayableImages(List<ActivityImage> images) {
    final List<ActivityImage> filtered = excludeThumbnails(images);
    return sortByDisplayOrder(filtered);
  }
}
