import 'package:ridingmate/features/auth/domain/repositories/google_auth_repository.dart';

class WithdrawWithGoogleUseCase {
  const WithdrawWithGoogleUseCase({required GoogleAuthRepository repository})
    : _repository = repository;

  final GoogleAuthRepository _repository;

  Future<void> execute() async {
    // TODO: 구글 계정 연결 해제(탈퇴) 구현
    // await _repository.disconnect();
  }
}
