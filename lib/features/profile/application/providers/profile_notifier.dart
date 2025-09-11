import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/profile/application/use_cases/get_profile_use_case.dart';
import 'package:urban_breeze/features/profile/application/use_cases/update_birth_use_case.dart';
import 'package:urban_breeze/features/profile/application/use_cases/update_gender_use_case.dart';
import 'package:urban_breeze/features/profile/application/use_cases/update_introduce_use_case.dart';
import 'package:urban_breeze/features/profile/application/use_cases/update_nickname_use_case.dart';
import 'package:urban_breeze/features/profile/domain/entities/profile.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<Profile?>> {
  ProfileNotifier({
    required GetProfileUseCase getProfileUseCase,
    required UpdateNicknameUseCase updateNicknameUseCase,
    required UpdateIntroduceUseCase updateIntroduceUseCase,
    required UpdateBirthUseCase updateBirthUseCase,
    required UpdateGenderUseCase updateGenderUseCase,
  }) : _getProfileUseCase = getProfileUseCase,
       _updateNicknameUseCase = updateNicknameUseCase,
       _updateIntroduceUseCase = updateIntroduceUseCase,
       _updateBirthUseCase = updateBirthUseCase,
       _updateGenderUseCase = updateGenderUseCase,
       super(const AsyncValue<Profile?>.loading());

  final GetProfileUseCase _getProfileUseCase;
  final UpdateNicknameUseCase _updateNicknameUseCase;
  final UpdateIntroduceUseCase _updateIntroduceUseCase;
  final UpdateBirthUseCase _updateBirthUseCase;
  final UpdateGenderUseCase _updateGenderUseCase;

  /// 프로필 정보 로드
  Future<void> loadProfile() async {
    // 로컬 데이터가 있으면 먼저 표시 (깜빡임 방지)
    if (state.hasValue && state.value != null) {
      // 이미 데이터가 있으면 서버에서 업데이트만
      final AppResult<Profile> result = await _getProfileUseCase.execute();
      if (result.isSuccess) {
        state = AsyncValue<Profile?>.data(result.dataOrNull);
      }
      return;
    }

    // 처음 로드할 때만 loading 상태
    state = const AsyncValue<Profile?>.loading();
    final AppResult<Profile> result = await _getProfileUseCase.execute();

    if (result.isSuccess) {
      state = AsyncValue<Profile?>.data(result.dataOrNull);
    } else {
      state = AsyncValue<Profile?>.error(
        result.exceptionOrNull ?? Exception('프로필 로드 실패'),
        StackTrace.current,
      );
    }
  }

  /// 닉네임 수정
  Future<void> updateNickname(String nickname) async {
    final AppResult<Profile> result = await _updateNicknameUseCase.execute(
      nickname,
    );

    if (result.isSuccess) {
      state = AsyncValue<Profile?>.data(result.dataOrNull);
    } else {
      state = AsyncValue<Profile?>.error(
        result.exceptionOrNull ?? Exception('닉네임 수정 실패'),
        StackTrace.current,
      );
    }
  }

  /// 자기소개 수정
  Future<void> updateIntroduce(String introduce) async {
    final AppResult<Profile> result = await _updateIntroduceUseCase.execute(
      introduce,
    );

    if (result.isSuccess) {
      state = AsyncValue<Profile?>.data(result.dataOrNull);
    } else {
      state = AsyncValue<Profile?>.error(
        result.exceptionOrNull ?? Exception('자기소개 수정 실패'),
        StackTrace.current,
      );
    }
  }

  /// 생년월일 수정
  Future<void> updateBirth(String birth) async {
    final AppResult<Profile> result = await _updateBirthUseCase.execute(birth);

    if (result.isSuccess) {
      state = AsyncValue<Profile?>.data(result.dataOrNull);
    } else {
      state = AsyncValue<Profile?>.error(
        result.exceptionOrNull ?? Exception('생년월일 수정 실패'),
        StackTrace.current,
      );
    }
  }

  /// 성별 수정
  Future<void> updateGender(String gender) async {
    final AppResult<Profile> result = await _updateGenderUseCase.execute(
      gender,
    );

    if (result.isSuccess) {
      state = AsyncValue<Profile?>.data(result.dataOrNull);
    } else {
      state = AsyncValue<Profile?>.error(
        result.exceptionOrNull ?? Exception('성별 수정 실패'),
        StackTrace.current,
      );
    }
  }
}
