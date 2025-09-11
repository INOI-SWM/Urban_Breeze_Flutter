import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/application/use_cases/base_profile_use_case.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase extends BaseProfileUseCase<void> {
  const GetProfileUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  @override
  Future<AppResult<User>> execute([void input]) async {
    return super.execute(input);
  }

  @override
  Future<User> performUpdate(void input) async {
    return _repository.getProfile();
  }

  @override
  String getErrorMessage() => '프로필 정보를 가져오는데 실패했습니다';
}
