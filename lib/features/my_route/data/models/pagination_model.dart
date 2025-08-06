class PaginationModel {
  const PaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      size: json['size'] as int,
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );
  }

  final int currentPage;
  final int totalPages;
  final int totalElements;
  final int size;
  final bool hasNext;
  final bool hasPrevious;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalElements': totalElements,
      'size': size,
      'hasNext': hasNext,
      'hasPrevious': hasPrevious,
    };
  }
}
