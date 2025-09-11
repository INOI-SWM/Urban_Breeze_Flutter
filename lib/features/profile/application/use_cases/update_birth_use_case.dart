import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateBirthUseCase {
  const UpdateBirthUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  Future<AppResult<User>> execute(String birth) async {
    try {
      final User updatedProfile = await _repository.updateBirth(birth.trim());
      return AppSuccess<User>(updatedProfile);
    } on NetworkException catch (e) {
      return AppFailure<User>(e);
    } catch (e) {
      return AppFailure<User>(
        ServerException('생년월일 수정에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
