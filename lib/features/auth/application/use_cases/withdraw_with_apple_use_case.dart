import 'package:ridingmate/features/auth/domain/repositories/apple_auth_repository.dart';

class WithdrawWithAppleUseCase {
  const WithdrawWithAppleUseCase({required AppleAuthRepository repository})
    : _repository = repository;

  final AppleAuthRepository _repository;

  Future<void> execute() async {
    // TODO: 애플 토큰 철회(탈퇴) 구현
    // await _repository.revokeTokens();
  }
}
