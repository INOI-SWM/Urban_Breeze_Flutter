import 'package:flutter/material.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/app_setting/domain/repositories/theme_mode_repository.dart';

class SaveThemeModeUseCase {
  SaveThemeModeUseCase({required this.repository});

  final ThemeModeRepository repository;

  Future<AppResult<void>> execute(ThemeMode themeMode) async {
    return await repository.saveThemeMode(themeMode);
  }
}
