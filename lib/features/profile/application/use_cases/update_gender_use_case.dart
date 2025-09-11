import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateGenderUseCase {
  const UpdateGenderUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  Future<AppResult<User>> execute(String gender) async {
    try {
      final User updatedUser = await _repository.updateGender(
        gender.trim().toUpperCase(),
      );
      return AppSuccess<User>(updatedUser);
    } on NetworkException catch (e) {
      return AppFailure<User>(e);
    } catch (e) {
      return AppFailure<User>(
        ServerException('성별 수정에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
