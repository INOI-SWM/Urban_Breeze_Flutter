import 'package:urban_breeze/features/auth/data/datasources/agreement_datasource.dart';
import 'package:urban_breeze/features/auth/domain/entities/user_agreement.dart';
import 'package:urban_breeze/features/auth/domain/repositories/agreement_repository.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class AgreementRepositoryImpl implements AgreementRepository {
  const AgreementRepositoryImpl({
    required AgreementDataSource dataSource,
  }) : _dataSource = dataSource;

  final AgreementDataSource _dataSource;

  @override
  Future<UserAgreement> updateAgreement(UserAgreement agreement) async {
    try {
      final ApiResponseModel<UserAgreement> response = 
          await _dataSource.updateAgreement(agreement);
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserAgreement> getAgreement() async {
    try {
      final ApiResponseModel<UserAgreement> response = 
          await _dataSource.getAgreement();
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
