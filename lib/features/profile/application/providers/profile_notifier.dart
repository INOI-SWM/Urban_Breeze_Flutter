import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/features/profile/domain/entities/profile.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<Profile?>> {
  ProfileNotifier({required ProfileRepository repository})
    : _repository = repository,
      super(const AsyncValue<Profile?>.loading());

  final ProfileRepository _repository;

  /// 프로필 정보 로드
  Future<void> loadProfile() async {
    state = const AsyncValue<Profile?>.loading();
    try {
      final Profile profile = await _repository.getProfile();
      state = AsyncValue<Profile?>.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue<Profile?>.error(error, stackTrace);
    }
  }

  /// 닉네임 수정
  Future<void> updateNickname(String nickname) async {
    try {
      final Profile updatedProfile = await _repository.updateNickname(nickname);
      state = AsyncValue<Profile?>.data(updatedProfile);
    } catch (error, stackTrace) {
      state = AsyncValue<Profile?>.error(error, stackTrace);
    }
  }

  /// 자기소개 수정
  Future<void> updateIntroduce(String introduce) async {
    try {
      final Profile updatedProfile = await _repository.updateIntroduce(
        introduce,
      );
      state = AsyncValue<Profile?>.data(updatedProfile);
    } catch (error, stackTrace) {
      state = AsyncValue<Profile?>.error(error, stackTrace);
    }
  }

  /// 생년월일 수정
  Future<void> updateBirth(String birth) async {
    try {
      final Profile updatedProfile = await _repository.updateBirth(birth);
      state = AsyncValue<Profile?>.data(updatedProfile);
    } catch (error, stackTrace) {
      state = AsyncValue<Profile?>.error(error, stackTrace);
    }
  }

  /// 성별 수정
  Future<void> updateGender(String gender) async {
    try {
      final Profile updatedProfile = await _repository.updateGender(gender);
      state = AsyncValue<Profile?>.data(updatedProfile);
    } catch (error, stackTrace) {
      state = AsyncValue<Profile?>.error(error, stackTrace);
    }
  }

  /// 프로필 정보 초기화
  void clearProfile() {
    state = const AsyncValue<Profile?>.data(null);
  }
}
