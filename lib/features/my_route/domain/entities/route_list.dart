import 'package:ridingmate/features/my_route/domain/entities/route.dart';

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
  });

  final List<MyRoute> routes;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final int size;
  final bool hasNext;
  final bool hasPrevious;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyRouteList &&
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
    return 'MyRouteList(routes: ${routes.length}, currentPage: $currentPage, totalPages: $totalPages)';
  }
}
