import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/auth/domain/entities/user_agreement.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class AgreementDataSource extends BaseRemoteDataSource {
  AgreementDataSource({super.client});

  /// 사용자 약관동의 정보를 업데이트합니다
  Future<ApiResponseModel<UserAgreement>> updateAgreement(
    UserAgreement agreement,
  ) async {
    try {
      final http.Response response = await put(
        ApiEndpoints.userAgreements,
        body: agreement.toJson(),
      );

      final Map<String, dynamic> responseData = decodeResponse(response);

      return ApiResponseModel<UserAgreement>.fromJson(
        responseData,
        (Map<String, dynamic> json) => UserAgreement.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
