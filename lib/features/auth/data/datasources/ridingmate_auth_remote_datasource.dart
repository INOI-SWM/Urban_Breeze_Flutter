import 'package:http/http.dart' as http;
import 'package:ridingmate/core/exceptions/base_domain_exception.dart';
import 'package:ridingmate/features/auth/data/models/ridingmate_login_response_model.dart';
import 'package:ridingmate/shared/api/data/datasources/base_remote_datasource.dart';

class RidingMateAuthRemoteDataSource extends BaseRemoteDataSource {
  RidingMateAuthRemoteDataSource({super.client});

  Future<RidingMateLoginResponseModel> loginWithGoogleIdToken({
    required String idToken,
  }) async {
    try {
      final http.Response response = await post(
        '/api/auth/google/login',
        body: <String, dynamic>{'idtoken': idToken},
      );

      final int statusCode = response.statusCode;
      final Map<String, dynamic> jsonMap = decodeResponse(response);

      if (statusCode == 200 || statusCode == 201) {
        return RidingMateLoginResponseModel.fromApi(jsonMap);
      } else {
        final String errorMessage =
            (jsonMap['errorMessage'] ?? jsonMap['message'] ?? 'API 요청 실패')
                .toString();
        throw ServerException('API 요청 실패 ($statusCode): $errorMessage');
      }
    } on ServerException {
      rethrow;
    }
  }
}
