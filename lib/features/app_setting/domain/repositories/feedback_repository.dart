import 'package:urban_breeze/features/app_setting/data/models/feedback_request_model.dart';
import 'package:urban_breeze/features/app_setting/data/models/feedback_response_model.dart';

abstract class FeedbackRepository {
  Future<FeedbackResponseModel> submitFeedback(FeedbackRequestModel request);
}
