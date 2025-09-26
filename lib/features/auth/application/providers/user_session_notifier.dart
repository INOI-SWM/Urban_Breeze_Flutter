import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/exceptions/validation_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/repositories/user_session_repository.dart';
import 'package:urban_breeze/features/profile/application/use_cases/get_profile_use_case.dart';
import 'package:urban_breeze/features/profile/application/use_cases/update_birth_use_case.dart';
import 'package:urban_breeze/features/profile/application/use_cases/update_gender_use_case.dart';
import 'package:urban_breeze/features/profile/application/use_cases/update_introduce_use_case.dart';
import 'package:urban_breeze/features/profile/application/use_cases/update_nickname_use_case.dart';

class UserSessionNotifier extends StateNotifier<User?> {
  UserSessionNotifier({
    required UserSessionRepository repository,
    required GetProfileUseCase getProfileUseCase,
    required UpdateNicknameUseCase updateNicknameUseCase,
    required UpdateIntroduceUseCase updateIntroduceUseCase,
    required UpdateBirthUseCase updateBirthUseCase,
    required UpdateGenderUseCase updateGenderUseCase,
    void Function()? onInitialized,
  }) : _repository = repository,
       _getProfileUseCase = getProfileUseCase,
       _updateNicknameUseCase = updateNicknameUseCase,
       _updateIntroduceUseCase = updateIntroduceUseCase,
       _updateBirthUseCase = updateBirthUseCase,
       _updateGenderUseCase = updateGenderUseCase,
       _onInitialized = onInitialized,
       super(null) {
    loadUserSession();
  }

  final UserSessionRepository _repository;
  final GetProfileUseCase _getProfileUseCase;
  final UpdateNicknameUseCase _updateNicknameUseCase;
  final UpdateIntroduceUseCase _updateIntroduceUseCase;
  final UpdateBirthUseCase _updateBirthUseCase;
  final UpdateGenderUseCase _updateGenderUseCase;
  final void Function()? _onInitialized;

  Future<void> setUserSession(User user) async {
    state = user;
    await _repository.saveUser(user);
    await AmplitudeAnalytics.setUserId(user.uuid, user.loginProvider.name);
  }

  Future<void> clearUserSession() async {
    // 로그아웃 이벤트 전송
    if (state != null) {
      try {
        await AmplitudeAnalytics.logEvent(
          'user_logout',
          properties: <String, dynamic>{
            'logout_reason': 'user_action',
            'login_provider': state!.loginProvider.name,
          },
        );
      } catch (e) {
        // 로그아웃 이벤트 전송 실패해도 로그아웃은 계속 진행
      }
    }

    // Amplitude 사용자 리셋
    try {
      await AmplitudeAnalytics.resetUser();
    } catch (e) {
      // Amplitude 리셋 실패해도 로그아웃은 계속 진행
    }

    state = null;
    await _repository.clearUser();
  }

  static const Duration _splashScreenDuration = Duration(milliseconds: 1000);

  Future<void> loadUserSession() async {
    // 최소 1초 지연으로 스플래시 화면이 충분히 보이도록
    await Future<void>.delayed(_splashScreenDuration);

    final User? savedUser = await _repository.loadUser();

    if (savedUser != null) {
      final AppResult<User> profileResult = await _getProfileUseCase.execute();

      if (profileResult.isSuccess) {
        state = profileResult.dataOrNull;
      } else {
        await clearUserSession();
      }
    } else {
      state = null;
    }

    // 초기화 완료 알림
    _onInitialized?.call();
  }

  bool get isLoggedIn => state != null;

  /// 공통 업데이트 로직을 처리하는 헬퍼 메서드
  Future<AppResult<User>> _executeUpdate(
    Future<AppResult<User>> Function() updateFunction,
  ) async {
    if (state == null) {
      return const AppFailure<User>(
        ValidationException(code: 'USER_NOT_LOGGED_IN'),
      );
    }

    final AppResult<User> result = await updateFunction();
    if (result.isSuccess) {
      state = result.dataOrNull;
    }
    return result;
  }

  /// 프로필 정보 새로고침
  Future<AppResult<User>> refreshProfile() async {
    return _executeUpdate(() => _getProfileUseCase.execute());
  }

  /// 닉네임 수정
  Future<AppResult<User>> updateNickname(String nickname) async {
    return _executeUpdate(() => _updateNicknameUseCase.execute(nickname));
  }

  /// 자기소개 수정
  Future<AppResult<User>> updateIntroduce(String introduce) async {
    return _executeUpdate(() => _updateIntroduceUseCase.execute(introduce));
  }

  /// 생년월일 수정
  Future<AppResult<User>> updateBirth(String birth) async {
    return _executeUpdate(() => _updateBirthUseCase.execute(birth));
  }

  /// 성별 수정
  Future<AppResult<User>> updateGender(String gender) async {
    return _executeUpdate(() => _updateGenderUseCase.execute(gender));
  }
}

class AuthInitializationNotifier extends StateNotifier<bool> {
  AuthInitializationNotifier() : super(false);

  void markInitialized() {
    state = true;
  }
}
