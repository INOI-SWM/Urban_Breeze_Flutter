import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/features/app_setting/data/models/feedback_request_model.dart';
import 'package:urban_breeze/features/app_setting/data/models/feedback_response_model.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class FeedbackDataSource extends BaseRemoteDataSource {
  FeedbackDataSource({super.client});

  Future<ApiResponseModel<FeedbackResponseModel>> submitFeedback(
    FeedbackRequestModel request,
  ) async {
    try {
      final http.Response response = await post(
        ApiEndpoints.feedback,
        body: request.toJson(),
      );

      final int statusCode = response.statusCode;
      final Map<String, dynamic> jsonMap = decodeResponse(response);

      if (statusCode == 201) {
        return ApiResponseModel<FeedbackResponseModel>.fromJson(
          jsonMap,
          (Map<String, dynamic> json) => FeedbackResponseModel.fromJson(json),
        );
      } else {
        final String errorMessage =
            (jsonMap['errorMessage'] ?? jsonMap['message'] ?? '피드백 전송 실패')
                .toString();
        throw ServerException('피드백 전송 실패 ($statusCode): $errorMessage');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('피드백 전송 중 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
