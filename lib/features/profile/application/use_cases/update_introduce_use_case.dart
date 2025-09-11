import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateIntroduceUseCase {
  const UpdateIntroduceUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  Future<AppResult<void>> execute(String introduce) async {
    // 자기소개 validation
    if (introduce.length > 100) {
      return const AppFailure<void>(
        ValidationException('자기소개는 100자 이하로 입력해주세요'),
      );
    }

    try {
      await _repository.updateIntroduce(introduce.trim());
      return const AppSuccess<void>(null);
    } on NetworkException catch (e) {
      return AppFailure<void>(e);
    } on ValidationException catch (e) {
      return AppFailure<void>(e);
    } catch (e) {
      return AppFailure<void>(
        ServerException('자기소개 수정에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
