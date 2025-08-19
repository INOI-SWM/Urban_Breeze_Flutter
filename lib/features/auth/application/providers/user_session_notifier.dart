import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/repositories/user_session_repository.dart';

class UserSessionNotifier extends StateNotifier<User?> {
  UserSessionNotifier({
    required UserSessionRepository repository,
    void Function()? onInitialized,
  }) : _repository = repository,
       _onInitialized = onInitialized,
       super(null) {
    loadUserSession();
  }

  final UserSessionRepository _repository;
  final void Function()? _onInitialized;

  Future<void> setUserSession(User user) async {
    state = user;
    await _repository.saveUser(user);
  }

  Future<void> clearUserSession() async {
    state = null;
    await _repository.clearUser();
  }

  static const Duration _splashScreenDuration = Duration(milliseconds: 1000);

  Future<void> loadUserSession() async {
    // 최소 1초 지연으로 스플래시 화면이 충분히 보이도록
    await Future<void>.delayed(_splashScreenDuration);
    final User? user = await _repository.loadUser();
    state = user;
    // 초기화 완료 알림
    _onInitialized?.call();
  }

  bool get isLoggedIn => state != null;
}

class AuthInitializationNotifier extends StateNotifier<bool> {
  AuthInitializationNotifier() : super(false);

  void markInitialized() {
    state = true;
  }
}
