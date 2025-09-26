import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/application/use_cases/base_profile_use_case.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class DeleteProfileImageUseCase extends BaseProfileUseCase<void> {
  const DeleteProfileImageUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  @override
  Future<User> performUpdate(void input) async {
    return _repository.deleteProfileImage();
  }

  @override
  String getErrorMessage() => '프로필 이미지 삭제에 실패했습니다';
}
