import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateNicknameUseCase {
  const UpdateNicknameUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  Future<AppResult<void>> execute(String nickname) async {
    // 닉네임 validation
    if (nickname.trim().isEmpty) {
      return const AppFailure<void>(ValidationException('닉네임을 입력해주세요'));
    }

    if (nickname.length > 20) {
      return const AppFailure<void>(ValidationException('닉네임은 20자 이하로 입력해주세요'));
    }

    try {
      await _repository.updateNickname(nickname.trim());
      return const AppSuccess<void>(null);
    } on NetworkException catch (e) {
      return AppFailure<void>(e);
    } on ValidationException catch (e) {
      return AppFailure<void>(e);
    } catch (e) {
      return AppFailure<void>(
        ServerException('닉네임 수정에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
