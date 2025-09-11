import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/profile/domain/entities/profile.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateIntroduceUseCase {
  const UpdateIntroduceUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  Future<AppResult<Profile>> execute(String introduce) async {
    // 자기소개 validation
    if (introduce.length > 100) {
      return const AppFailure<Profile>(
        ValidationException('자기소개는 100자 이하로 입력해주세요'),
      );
    }

    try {
      final Profile updatedProfile = await _repository.updateIntroduce(
        introduce.trim(),
      );
      return AppSuccess<Profile>(updatedProfile);
    } on NetworkException catch (e) {
      return AppFailure<Profile>(e);
    } on ValidationException catch (e) {
      return AppFailure<Profile>(e);
    } catch (e) {
      return AppFailure<Profile>(
        ServerException('자기소개 수정에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
