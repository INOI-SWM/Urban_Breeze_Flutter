import '../entities/profile.dart';

abstract class ProfileRepository {
  /// 프로필 정보 조회
  Future<Profile> getProfile();

  /// 닉네임 수정
  Future<Profile> updateNickname(String nickname);

  /// 자기소개 수정
  Future<Profile> updateIntroduce(String introduce);

  /// 생년월일 수정
  Future<Profile> updateBirth(String birth);

  /// 성별 수정
  Future<Profile> updateGender(String gender);
}
