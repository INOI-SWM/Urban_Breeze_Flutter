class ActivityImage {
  const ActivityImage({
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
    return other is ActivityImage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ActivityImage(id: $id, imageUrl: $imageUrl, displayOrder: $displayOrder)';
  }
}
