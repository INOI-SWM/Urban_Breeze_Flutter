import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/profile/domain/entities/profile.dart';
import 'package:urban_breeze/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  Future<AppResult<Profile>> execute() async {
    try {
      final Profile profile = await _repository.getProfile();
      return AppSuccess<Profile>(profile);
    } on NetworkException catch (e) {
      return AppFailure<Profile>(e);
    } catch (e) {
      return AppFailure<Profile>(
        ServerException('프로필 정보를 가져오는데 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
