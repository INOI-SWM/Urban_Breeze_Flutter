import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/application/use_cases/base_profile_use_case.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateGenderUseCase extends BaseProfileUseCase<String> {
  const UpdateGenderUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  @override
  Future<AppResult<User>> execute(String input) async {
    return super.execute(input.trim().toUpperCase());
  }

  @override
  Future<User> performUpdate(String input) async {
    return _repository.updateGender(input);
  }

  @override
  String getErrorMessage() => '성별 수정에 실패했습니다';
}
