import 'package:ridingmate/features/my_route/domain/entities/route.dart';

class RouteList {
  /// 빈 경로 목록 생성
  factory RouteList.empty() {
    return const RouteList(
      routes: <Route>[],
      currentPage: 0,
      totalPages: 0,
      totalElements: 0,
      size: 0,
      hasNext: false,
      hasPrevious: false,
    );
  }
  const RouteList({
    required this.routes,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.hasNext,
    required this.hasPrevious,
  });

  final List<Route> routes;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final int size;
  final bool hasNext;
  final bool hasPrevious;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteList &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.totalElements == totalElements;
  }

  @override
  int get hashCode {
    return Object.hash(currentPage, totalPages, totalElements);
  }

  @override
  String toString() {
    return 'RouteList(routes: ${routes.length}, currentPage: $currentPage, totalPages: $totalPages)';
  }
}
