import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateBirthUseCase {
  const UpdateBirthUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  Future<AppResult<void>> execute(String birth) async {
    try {
      await _repository.updateBirth(birth.trim());
      return const AppSuccess<void>(null);
    } on NetworkException catch (e) {
      return AppFailure<void>(e);
    } catch (e) {
      return AppFailure<void>(
        ServerException('생년월일 수정에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
