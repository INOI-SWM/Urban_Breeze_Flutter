import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/features/auth/data/models/urban_breeze_login_response_model.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';

class UrbanBreezeAuthRemoteDataSource extends BaseRemoteDataSource {
  UrbanBreezeAuthRemoteDataSource({super.client});

  Future<UrbanBreezeLoginResponseModel> loginWithGoogleIdToken({
    required String idToken,
  }) async {
    try {
      final http.Response response = await post(
        ApiEndpoints.googleLogin,
        body: <String, dynamic>{'idToken': idToken},
      );

      final int statusCode = response.statusCode;
      final Map<String, dynamic> jsonMap = decodeResponse(response);

      if (statusCode == 200 || statusCode == 201) {
        return UrbanBreezeLoginResponseModel.fromApi(
          jsonMap,
          LoginProvider.google,
        );
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

  Future<UrbanBreezeLoginResponseModel> loginWithKakaoAccessToken({
    required String accessToken,
  }) async {
    try {
      final http.Response response = await post(
        ApiEndpoints.kakaoLogin,
        body: <String, dynamic>{'accessToken': accessToken},
      );

      final int statusCode = response.statusCode;
      final Map<String, dynamic> jsonMap = decodeResponse(response);

      if (statusCode == 200 || statusCode == 201) {
        return UrbanBreezeLoginResponseModel.fromApi(
          jsonMap,
          LoginProvider.kakao,
        );
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

  Future<UrbanBreezeLoginResponseModel> loginWithAppleIdToken({
    required String idToken,
  }) async {
    try {
      final http.Response response = await post(
        ApiEndpoints.appleLogin,
        body: <String, dynamic>{'idToken': idToken},
      );

      final int statusCode = response.statusCode;
      final Map<String, dynamic> jsonMap = decodeResponse(response);

      if (statusCode == 200 || statusCode == 201) {
        return UrbanBreezeLoginResponseModel.fromApi(
          jsonMap,
          LoginProvider.apple,
        );
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
