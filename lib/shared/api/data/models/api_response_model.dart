class ApiResponseModel<T> {
  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponseModel<T>(
      code: json['code'] as String,
      message: json['message'] as String,
      data: fromJsonT(json['data'] as Map<String, dynamic>),
    );
  }

  const ApiResponseModel({
    this.code,
    required this.message,
    required this.data,
  });

  final String? code;
  final String message;
  final T data;
}
