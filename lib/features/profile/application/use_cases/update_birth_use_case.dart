import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/application/use_cases/base_profile_use_case.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateBirthUseCase extends BaseProfileUseCase<String> {
  const UpdateBirthUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  @override
  Future<AppResult<User>> execute(String input) async {
    return super.execute(input.trim());
  }

  @override
  Future<User> performUpdate(String input) async {
    return _repository.updateBirth(input);
  }

  @override
  String getErrorMessage() => '생년월일 수정에 실패했습니다';
}
