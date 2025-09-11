import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/profile.dart';
import '../constants/profile_keys.dart';

class ProfileLocalDataSource {
  const ProfileLocalDataSource();

  Future<SharedPreferences> get _sharedPreferences async {
    return await SharedPreferences.getInstance();
  }

  /// 프로필 정보 저장
  Future<void> saveProfile(Profile profile) async {
    final SharedPreferences prefs = await _sharedPreferences;
    await Future.wait(<Future<bool>>[
      if (profile.nickname.isNotEmpty)
        prefs.setString(ProfileKeys.nickname, profile.nickname),
      if (profile.introduce != null)
        prefs.setString(ProfileKeys.introduce, profile.introduce!),
      if (profile.birth != null)
        prefs.setString(ProfileKeys.birth, profile.birth!),
      if (profile.gender != null)
        prefs.setString(ProfileKeys.gender, profile.gender!),
    ]);
  }

  /// 프로필 정보 로드
  Future<Profile?> loadProfile() async {
    final SharedPreferences prefs = await _sharedPreferences;
    final String? nickname = prefs.getString(ProfileKeys.nickname);

    if (nickname == null || nickname.isEmpty) {
      return null;
    }

    return Profile(
      nickname: nickname,
      introduce: prefs.getString(ProfileKeys.introduce),
      birth: prefs.getString(ProfileKeys.birth),
      gender: prefs.getString(ProfileKeys.gender),
    );
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
