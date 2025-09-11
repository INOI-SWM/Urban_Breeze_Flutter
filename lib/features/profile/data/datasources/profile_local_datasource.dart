import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/profile.dart';
import '../constants/profile_keys.dart';

class ProfileLocalDataSource {
  const ProfileLocalDataSource({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  /// 프로필 정보 저장
  Future<void> saveProfile(Profile profile) async {
    await Future.wait(<Future<bool>>[
      if (profile.nickname.isNotEmpty)
        _sharedPreferences.setString(ProfileKeys.nickname, profile.nickname),
      if (profile.introduce != null)
        _sharedPreferences.setString(ProfileKeys.introduce, profile.introduce!),
      if (profile.birth != null)
        _sharedPreferences.setString(ProfileKeys.birth, profile.birth!),
      if (profile.gender != null)
        _sharedPreferences.setString(ProfileKeys.gender, profile.gender!),
    ]);
  }

  /// 프로필 정보 로드
  Profile? loadProfile() {
    final String? nickname = _sharedPreferences.getString(ProfileKeys.nickname);

    if (nickname == null || nickname.isEmpty) {
      return null;
    }

    return Profile(
      nickname: nickname,
      introduce: _sharedPreferences.getString(ProfileKeys.introduce),
      birth: _sharedPreferences.getString(ProfileKeys.birth),
      gender: _sharedPreferences.getString(ProfileKeys.gender),
    );
  }

  /// 특정 필드 업데이트
  Future<void> updateNickname(String nickname) async {
    await _sharedPreferences.setString(ProfileKeys.nickname, nickname);
  }

  Future<void> updateIntroduce(String introduce) async {
    await _sharedPreferences.setString(ProfileKeys.introduce, introduce);
  }

  Future<void> updateBirth(String birth) async {
    await _sharedPreferences.setString(ProfileKeys.birth, birth);
  }

  Future<void> updateGender(String gender) async {
    await _sharedPreferences.setString(ProfileKeys.gender, gender);
  }

  /// 프로필 정보 삭제
  Future<void> clearProfile() async {
    await Future.wait(<Future<bool>>[
      _sharedPreferences.remove(ProfileKeys.nickname),
      _sharedPreferences.remove(ProfileKeys.introduce),
      _sharedPreferences.remove(ProfileKeys.birth),
      _sharedPreferences.remove(ProfileKeys.gender),
    ]);
  }
}
