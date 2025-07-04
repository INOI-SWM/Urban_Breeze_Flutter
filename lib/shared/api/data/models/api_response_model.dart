class ApiResponseModel<T> {
  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponseModel<T>(
      status: json['status'] as int,
      message: json['message'] as String,
      data: fromJsonT(json['data'] as Map<String, dynamic>),
    );
  }
  const ApiResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final int status;
  final String message;
  final T data;
}
