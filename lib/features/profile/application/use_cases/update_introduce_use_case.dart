import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateIntroduceUseCase {
  const UpdateIntroduceUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  Future<AppResult<User>> execute(String introduce) async {
    // 자기소개 validation
    if (introduce.length > 100) {
      return const AppFailure<User>(
        ValidationException('자기소개는 100자 이하로 입력해주세요'),
      );
    }

    try {
      final User updatedUser = await _repository.updateIntroduce(
        introduce.trim(),
      );
      return AppSuccess<User>(updatedUser);
    } on NetworkException catch (e) {
      return AppFailure<User>(e);
    } on ValidationException catch (e) {
      return AppFailure<User>(e);
    } catch (e) {
      return AppFailure<User>(
        ServerException('자기소개 수정에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
