import 'package:http/http.dart' as http;
import 'package:ridingmate/core/exceptions/base_domain_exception.dart';
import 'package:ridingmate/features/auth/data/models/ridingmate_login_response_model.dart';
import 'package:ridingmate/features/auth/domain/enums/login_provider.dart';
import 'package:ridingmate/shared/api/data/datasources/base_remote_datasource.dart';

class RidingMateAuthRemoteDataSource extends BaseRemoteDataSource {
  RidingMateAuthRemoteDataSource({super.client});

  Future<RidingMateLoginResponseModel> loginWithGoogleIdToken({
    required String idToken,
  }) async {
    try {
      final http.Response response = await post(
        '/api/auth/google/login',
        body: <String, dynamic>{'idToken': idToken},
      );

      final int statusCode = response.statusCode;
      final Map<String, dynamic> jsonMap = decodeResponse(response);

      if (statusCode == 200 || statusCode == 201) {
        return RidingMateLoginResponseModel.fromApi(
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

  Future<RidingMateLoginResponseModel> loginWithKakaoAccessToken({
    required String accessToken,
  }) async {
    try {
      final http.Response response = await post(
        '/api/auth/kakao/login',
        body: <String, dynamic>{'accessToken': accessToken},
      );

      final int statusCode = response.statusCode;
      final Map<String, dynamic> jsonMap = decodeResponse(response);

      if (statusCode == 200 || statusCode == 201) {
        return RidingMateLoginResponseModel.fromApi(
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

  Future<RidingMateLoginResponseModel> loginWithAppleIdToken({
    required String idToken,
  }) async {
    try {
      final http.Response response = await post(
        '/api/auth/apple/login',
        body: <String, dynamic>{'idToken': idToken},
      );

      final int statusCode = response.statusCode;
      final Map<String, dynamic> jsonMap = decodeResponse(response);

      if (statusCode == 200 || statusCode == 201) {
        return RidingMateLoginResponseModel.fromApi(
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
