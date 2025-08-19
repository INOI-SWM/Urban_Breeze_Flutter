import 'package:urban_breeze/features/auth/domain/repositories/kakao_auth_repository.dart';

class WithdrawWithKakaoUseCase {
  const WithdrawWithKakaoUseCase({required KakaoAuthRepository repository})
    : _repository = repository;

  final KakaoAuthRepository _repository;

  Future<void> execute() async {
    await _repository.withdraw();
  }
}
