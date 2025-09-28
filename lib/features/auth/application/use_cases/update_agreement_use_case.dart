import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user_agreement.dart';
import 'package:urban_breeze/features/auth/domain/repositories/agreement_repository.dart';

class UpdateAgreementUseCase {
  const UpdateAgreementUseCase({required AgreementRepository repository})
    : _repository = repository;

  final AgreementRepository _repository;

  Future<AppResult<UserAgreement>> execute(UserAgreement agreement) async {
    try {
      final UserAgreement result = await _repository.updateAgreement(agreement);
      return AppSuccess<UserAgreement>(result);
    } on NetworkException catch (e) {
      return AppFailure<UserAgreement>(e);
    } on ServerException catch (e) {
      return AppFailure<UserAgreement>(e);
    } catch (e) {
      return AppFailure<UserAgreement>(
        ServerException('약관동의 업데이트에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
