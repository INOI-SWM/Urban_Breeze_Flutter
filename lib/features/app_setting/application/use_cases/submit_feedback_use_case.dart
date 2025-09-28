import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/app_setting/data/models/feedback_request_model.dart';
import 'package:urban_breeze/features/app_setting/data/models/feedback_response_model.dart';
import 'package:urban_breeze/features/app_setting/domain/repositories/feedback_repository.dart';

class SubmitFeedbackUseCase {
  const SubmitFeedbackUseCase({required FeedbackRepository repository})
    : _repository = repository;

  final FeedbackRepository _repository;

  Future<AppResult<FeedbackResponseModel>> execute(String content) async {
    try {
      final FeedbackRequestModel request = FeedbackRequestModel(
        content: content,
      );
      final FeedbackResponseModel result = await _repository.submitFeedback(
        request,
      );
      return AppSuccess<FeedbackResponseModel>(result);
    } on NetworkException catch (e) {
      return AppFailure<FeedbackResponseModel>(e);
    } on ServerException catch (e) {
      return AppFailure<FeedbackResponseModel>(e);
    } catch (e) {
      return AppFailure<FeedbackResponseModel>(
        ServerException('피드백 전송에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
