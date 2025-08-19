import 'package:urban_breeze/features/auth/domain/repositories/google_auth_repository.dart';

class WithdrawWithGoogleUseCase {
  const WithdrawWithGoogleUseCase({required GoogleAuthRepository repository})
    : _repository = repository;

  final GoogleAuthRepository _repository;

  Future<void> execute() async {
    await _repository.withdraw();
  }
}
