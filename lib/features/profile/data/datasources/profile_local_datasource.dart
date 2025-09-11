import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';

import '../constants/profile_keys.dart';

class ProfileLocalDataSource {
  const ProfileLocalDataSource();

  Future<SharedPreferences> get _sharedPreferences async {
    return await SharedPreferences.getInstance();
  }

  /// 프로필 정보 저장
  Future<void> saveProfile(User user) async {
    final SharedPreferences prefs = await _sharedPreferences;
    await Future.wait(<Future<bool>>[
      if (user.nickname.isNotEmpty)
        prefs.setString(ProfileKeys.nickname, user.nickname),
      if (user.introduce != null)
        prefs.setString(ProfileKeys.introduce, user.introduce!),
      if (user.birthYear != null)
        prefs.setString(ProfileKeys.birth, user.birthYear!.toString()),
      if (user.gender != null)
        prefs.setString(ProfileKeys.gender, user.gender!),
      prefs.setString(ProfileKeys.loginProvider, user.loginProvider.name),
    ]);
  }

  /// 특정 필드 업데이트
  Future<void> updateNickname(String nickname) async {
    final SharedPreferences prefs = await _sharedPreferences;
    await prefs.setString(ProfileKeys.nickname, nickname);
  }

  Future<void> updateIntroduce(String introduce) async {
    final SharedPreferences prefs = await _sharedPreferences;
    await prefs.setString(ProfileKeys.introduce, introduce);
  }

  Future<void> updateBirth(String birth) async {
    final SharedPreferences prefs = await _sharedPreferences;
    await prefs.setString(ProfileKeys.birth, birth);
  }

  Future<void> updateGender(String gender) async {
    final SharedPreferences prefs = await _sharedPreferences;
    await prefs.setString(ProfileKeys.gender, gender);
  }
}
