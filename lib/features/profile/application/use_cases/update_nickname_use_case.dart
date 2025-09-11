import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/profile/domain/entities/profile.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateNicknameUseCase {
  const UpdateNicknameUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  Future<AppResult<Profile>> execute(String nickname) async {
    // 닉네임 validation
    if (nickname.trim().isEmpty) {
      return const AppFailure<Profile>(ValidationException('닉네임을 입력해주세요'));
    }

    if (nickname.length > 20) {
      return const AppFailure<Profile>(
        ValidationException('닉네임은 20자 이하로 입력해주세요'),
      );
    }

    try {
      final Profile updatedProfile = await _repository.updateNickname(
        nickname.trim(),
      );
      return AppSuccess<Profile>(updatedProfile);
    } on NetworkException catch (e) {
      return AppFailure<Profile>(e);
    } on ValidationException catch (e) {
      return AppFailure<Profile>(e);
    } catch (e) {
      return AppFailure<Profile>(
        ServerException('닉네임 수정에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
