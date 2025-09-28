import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';
import 'package:urban_breeze/features/app_setting/application/services/account_management_controller.dart';
import 'package:urban_breeze/features/app_setting/application/use_cases/submit_feedback_use_case.dart';
import 'package:urban_breeze/features/app_setting/data/datasources/feedback_datasource.dart';
import 'package:urban_breeze/features/app_setting/data/repositories/feedback_repository_impl.dart';
import 'package:urban_breeze/features/app_setting/domain/repositories/feedback_repository.dart';

// Feedback Providers
final Provider<FeedbackDataSource> feedbackDataSourceProvider =
    Provider<FeedbackDataSource>((Ref ref) {
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return FeedbackDataSource(client: client);
    });

final Provider<FeedbackRepository> feedbackRepositoryProvider =
    Provider<FeedbackRepository>((Ref ref) {
      final FeedbackDataSource dataSource = ref.watch(
        feedbackDataSourceProvider,
      );
      return FeedbackRepositoryImpl(dataSource: dataSource);
    });

final Provider<SubmitFeedbackUseCase> submitFeedbackUseCaseProvider =
    Provider<SubmitFeedbackUseCase>((Ref ref) {
      final FeedbackRepository repository = ref.watch(
        feedbackRepositoryProvider,
      );
      return SubmitFeedbackUseCase(repository: repository);
    });

// Account Management Provider
final Provider<AccountManagementController>
accountManagementControllerProvider = Provider<AccountManagementController>((
  Ref ref,
) {
  return AccountManagementController(ref);
});
