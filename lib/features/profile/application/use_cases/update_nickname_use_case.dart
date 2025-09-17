import 'package:urban_breeze/core/exceptions/validation_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/application/use_cases/base_profile_use_case.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateNicknameUseCase extends BaseProfileUseCase<String> {
  const UpdateNicknameUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  @override
  Future<AppResult<User>> execute(String input) async {
    // 닉네임 validation
    if (input.trim().isEmpty) {
      return const AppFailure<User>(
        ValidationException(code: 'NICKNAME_EMPTY'),
      );
    }

    if (input.length > 20) {
      return const AppFailure<User>(
        ValidationException(code: 'NICKNAME_TOO_LONG'),
      );
    }

    return super.execute(input.trim());
  }

  @override
  Future<User> performUpdate(String nickname) async {
    return _repository.updateNickname(nickname);
  }

  @override
  String getErrorMessage() => '닉네임 수정에 실패했습니다';
}
