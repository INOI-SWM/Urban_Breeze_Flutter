import 'package:urban_breeze/features/my_route/domain/entities/my_route.dart';

class MyRouteList {
  factory MyRouteList.empty() {
    return const MyRouteList(
      routes: <MyRoute>[],
      currentPage: 0,
      totalPages: 0,
      totalElements: 0,
      size: 0,
      hasNext: false,
      hasPrevious: false,
      maxDistance: 0,
      maxElevationGain: 0,
    );
  }
  const MyRouteList({
    required this.routes,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.hasNext,
    required this.hasPrevious,
    required this.maxDistance,
    required this.maxElevationGain,
  });

  final List<MyRoute> routes;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final int size;
  final bool hasNext;
  final bool hasPrevious;
  final double maxDistance;
  final double maxElevationGain;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyRouteList &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.totalElements == totalElements &&
        other.maxDistance == maxDistance &&
        other.maxElevationGain == maxElevationGain;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentPage,
      totalPages,
      totalElements,
      maxDistance,
      maxElevationGain,
    );
  }

  @override
  String toString() {
    return 'MyRouteList(routes: ${routes.length}, currentPage: $currentPage, totalPages: $totalPages, totalElements: $totalElements, size: $size, hasNext: $hasNext, hasPrevious: $hasPrevious, maxDistance: $maxDistance, maxElevationGain: $maxElevationGain)';
  }
}
