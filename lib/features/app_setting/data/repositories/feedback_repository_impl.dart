import 'package:urban_breeze/features/app_setting/data/datasources/feedback_datasource.dart';
import 'package:urban_breeze/features/app_setting/data/models/feedback_request_model.dart';
import 'package:urban_breeze/features/app_setting/data/models/feedback_response_model.dart';
import 'package:urban_breeze/features/app_setting/domain/repositories/feedback_repository.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  const FeedbackRepositoryImpl({required FeedbackDataSource dataSource})
    : _dataSource = dataSource;

  final FeedbackDataSource _dataSource;

  @override
  Future<FeedbackResponseModel> submitFeedback(
    FeedbackRequestModel request,
  ) async {
    try {
      final ApiResponseModel<FeedbackResponseModel> response = await _dataSource
          .submitFeedback(request);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
