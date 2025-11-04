import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/app_setting/domain/repositories/theme_mode_repository.dart';

class ThemeModeRepositoryImpl implements ThemeModeRepository {
  static const String _themeModeKey = 'theme_mode';

  @override
  Future<AppResult<ThemeMode>> getThemeMode() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? themeModeString = prefs.getString(_themeModeKey);

      if (themeModeString == null) {
        return const AppSuccess<ThemeMode>(ThemeMode.system);
      }

      final ThemeMode themeMode = ThemeMode.values.firstWhere(
        (ThemeMode mode) => mode.name == themeModeString,
        orElse: () => ThemeMode.system,
      );

      return AppSuccess<ThemeMode>(themeMode);
    } catch (e) {
      return AppFailure<ThemeMode>(
        LocalStorageException('테마 모드를 불러오는데 실패했습니다: ${e.toString()}'),
      );
    }
  }

  @override
  Future<AppResult<void>> saveThemeMode(ThemeMode themeMode) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, themeMode.name);
      return const AppSuccess<void>(null);
    } catch (e) {
      return AppFailure<void>(
        LocalStorageException('테마 모드를 저장하는데 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
