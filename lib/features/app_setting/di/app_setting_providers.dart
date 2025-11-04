import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/app_setting/application/services/account_management_controller.dart';
import 'package:urban_breeze/features/app_setting/application/use_cases/get_theme_mode_use_case.dart';
import 'package:urban_breeze/features/app_setting/application/use_cases/save_theme_mode_use_case.dart';
import 'package:urban_breeze/features/app_setting/application/use_cases/submit_feedback_use_case.dart';
import 'package:urban_breeze/features/app_setting/data/datasources/feedback_datasource.dart';
import 'package:urban_breeze/features/app_setting/data/repositories/feedback_repository_impl.dart';
import 'package:urban_breeze/features/app_setting/data/repositories/theme_mode_repository_impl.dart';
import 'package:urban_breeze/features/app_setting/domain/repositories/feedback_repository.dart';
import 'package:urban_breeze/features/app_setting/domain/repositories/theme_mode_repository.dart';

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

// Theme Mode Providers
final Provider<ThemeModeRepository> themeModeRepositoryProvider =
    Provider<ThemeModeRepository>((Ref ref) {
      return ThemeModeRepositoryImpl();
    });

final Provider<GetThemeModeUseCase> getThemeModeUseCaseProvider =
    Provider<GetThemeModeUseCase>((Ref ref) {
      final ThemeModeRepository repository = ref.watch(
        themeModeRepositoryProvider,
      );
      return GetThemeModeUseCase(repository: repository);
    });

final Provider<SaveThemeModeUseCase> saveThemeModeUseCaseProvider =
    Provider<SaveThemeModeUseCase>((Ref ref) {
      final ThemeModeRepository repository = ref.watch(
        themeModeRepositoryProvider,
      );
      return SaveThemeModeUseCase(repository: repository);
    });

final StateNotifierProvider<ThemeModeNotifier, ThemeMode>
themeModeNotifierProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (Ref ref) {
    return ThemeModeNotifier(ref);
  },
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this.ref) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final Ref ref;

  Future<void> _loadThemeMode() async {
    final GetThemeModeUseCase useCase = ref.read(getThemeModeUseCaseProvider);
    final AppResult<ThemeMode> result = await useCase.execute();
    if (result.isSuccess && result.dataOrNull != null) {
      state = result.dataOrNull!;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final SaveThemeModeUseCase useCase = ref.read(saveThemeModeUseCaseProvider);
    final AppResult<void> result = await useCase.execute(themeMode);
    if (result.isSuccess) {
      state = themeMode;
    }
  }
}
