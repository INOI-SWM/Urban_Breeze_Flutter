import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateGenderUseCase {
  const UpdateGenderUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  Future<AppResult<void>> execute(String gender) async {
    try {
      await _repository.updateGender(gender.trim().toUpperCase());
      return const AppSuccess<void>(null);
    } on NetworkException catch (e) {
      return AppFailure<void>(e);
    } catch (e) {
      return AppFailure<void>(
        ServerException('성별 수정에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
