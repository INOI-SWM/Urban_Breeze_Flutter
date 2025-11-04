import 'package:flutter/material.dart';
import 'package:urban_breeze/core/result/app_result.dart';

abstract class ThemeModeRepository {
  Future<AppResult<ThemeMode>> getThemeMode();
  Future<AppResult<void>> saveThemeMode(ThemeMode themeMode);
}
