import 'package:urban_breeze/core/exceptions/validation_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/application/use_cases/base_profile_use_case.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class UpdateIntroduceUseCase extends BaseProfileUseCase<String> {
  const UpdateIntroduceUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  @override
  Future<AppResult<User>> execute(String input) async {
    // 자기소개 validation
    if (input.length > 100) {
      return const AppFailure<User>(
        ValidationException(
          code: 'INTRODUCE_TOO_LONG',
          data: <String, dynamic>{'maxLength': 100},
          message: '자기소개는 100자 이하로 입력해주세요',
        ),
      );
    }

    return super.execute(input.trim());
  }

  @override
  Future<User> performUpdate(String input) async {
    return _repository.updateIntroduce(input);
  }

  @override
  String getErrorMessage() => '자기소개 수정에 실패했습니다';
}
