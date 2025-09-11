import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/profile/domain/entities/profile.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateBirthUseCase {
  const UpdateBirthUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  Future<AppResult<Profile>> execute(String birth) async {
    try {
      final Profile updatedProfile = await _repository.updateBirth(
        birth.trim(),
      );
      return AppSuccess<Profile>(updatedProfile);
    } on NetworkException catch (e) {
      return AppFailure<Profile>(e);
    } catch (e) {
      return AppFailure<Profile>(
        ServerException('생년월일 수정에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
