import 'package:ridingmate/shared/api/data/models/api_error_model.dart';

class ApiResponseModel<T> {
  factory ApiResponseModel.success(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponseModel<T>(
      code: null,
      message: json['message'] as String,
      data: fromJsonT(json['data'] as Map<String, dynamic>),
      errors: null,
    );
  }

  factory ApiResponseModel.error(Map<String, dynamic> json) {
    return ApiResponseModel<T>(
      code: json['code'] as String,
      message: json['message'] as String,
      data: null,
      errors:
          json['errors'] != null
              ? ApiErrorModel.fromJson(json['errors'] as Map<String, dynamic>)
              : null,
    );
  }

  const ApiResponseModel({
    this.code,
    required this.message,
    this.data,
    this.errors,
  });

  final String? code;
  final String message;
  final T? data;
  final ApiErrorModel? errors;
}
