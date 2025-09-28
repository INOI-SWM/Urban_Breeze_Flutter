import 'package:urban_breeze/features/auth/domain/entities/user_agreement.dart';

abstract class AgreementRepository {
  Future<UserAgreement> updateAgreement(UserAgreement agreement);
}
