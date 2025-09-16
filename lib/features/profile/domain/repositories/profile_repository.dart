import 'dart:io';

import 'package:urban_breeze/features/auth/domain/entities/user.dart';

abstract class ProfileRepository {
  /// 프로필 정보 조회
  Future<User> getProfile();

  /// 닉네임 수정
  Future<User> updateNickname(String nickname);

  /// 자기소개 수정
  Future<User> updateIntroduce(String introduce);

  /// 생년월일 수정
  Future<User> updateBirth(String birth);

  /// 성별 수정
  Future<User> updateGender(String gender);

  /// 프로필 이미지 업로드
  Future<User> uploadProfileImage(File imageFile);
}
