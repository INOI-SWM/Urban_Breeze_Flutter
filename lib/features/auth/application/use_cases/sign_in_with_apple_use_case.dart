import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/auth/domain/repositories/apple_auth_repository.dart';

class SignInWithAppleUseCase {
  const SignInWithAppleUseCase({required AppleAuthRepository repository})
    : _repository = repository;

  final AppleAuthRepository _repository;

  Future<User?> execute() async {
    // apple의 경우, 첫 로그인 시에만 이름과 이메일을 받을 수 있음

    final User? user = await _repository.signIn();

    // TODO: 첫 로그인, 2번쨰 로그인 판단하여 첫 로그인 시 서버에 정보저장, 두번쨰 로그인 부터 이름과 이메일 받아오기.
    // TODO: 로그인 실패 예외처리 추가
    // --  구현을 위한 임시코드  -- //
    if (user == null) return null;
    if (user.email == '') {
      final User newUser = User(
        id: user.id,
        email: 'nobin313@gmail.com',
        displayName: 'jongbin Noh',
        photoUrl: 'https://swmaestro.org/static/sw/img/mypage/ico-9.png',
        loginProvider: user.loginProvider,
      );
      return newUser;
    }
    return user;
  }
}
