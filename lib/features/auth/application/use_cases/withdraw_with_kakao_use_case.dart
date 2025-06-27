import 'package:ridingmate/features/auth/domain/repositories/kakao_auth_repository.dart';

class WithdrawWithKakaoUseCase {
  const WithdrawWithKakaoUseCase({required KakaoAuthRepository repository})
    : _repository = repository;

  final KakaoAuthRepository _repository;

  Future<void> execute() async {
    // TODO: 카카오 연결끊기(탈퇴) 구현
    // await _repository.withdraw();
  }
}
