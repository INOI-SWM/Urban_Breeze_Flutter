import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/profile/data/models/profile_model.dart';
import 'package:urban_breeze/features/profile/data/models/profile_update_request_model.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class ProfileDataSource extends BaseRemoteDataSource {
  ProfileDataSource({super.client});

  /// 프로필 정보 조회
  Future<ApiResponseModel<ProfileModel>> getProfile() async {
    try {
      final http.Response response = await get(ApiEndpoints.profile);
      final Map<String, dynamic> responseData = decodeResponse(response);

      return ApiResponseModel<ProfileModel>.fromJson(
        responseData,
        ProfileModel.fromJson,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 닉네임 수정
  Future<ApiResponseModel<void>> updateNickname(String nickname) async {
    try {
      final ProfileUpdateRequestModel requestModel = ProfileUpdateRequestModel(
        value: nickname,
      );

      final http.Response response = await put(
        ApiEndpoints.profileNickname,
        body: requestModel.toJson(),
      );
      final Map<String, dynamic> responseData = decodeResponse(response);

      return ApiResponseModel<void>.fromJson(
        responseData,
        (Map<String, dynamic> json) {},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 자기소개 수정
  Future<ApiResponseModel<void>> updateIntroduce(String introduce) async {
    try {
      final ProfileUpdateRequestModel requestModel = ProfileUpdateRequestModel(
        value: introduce,
      );

      final http.Response response = await put(
        ApiEndpoints.profileIntroduce,
        body: requestModel.toJson(),
      );
      final Map<String, dynamic> responseData = decodeResponse(response);

      return ApiResponseModel<void>.fromJson(
        responseData,
        (Map<String, dynamic> json) {},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 생년월일 수정
  Future<ApiResponseModel<void>> updateBirth(String birth) async {
    try {
      final ProfileUpdateRequestModel requestModel = ProfileUpdateRequestModel(
        value: birth,
      );

      final http.Response response = await put(
        ApiEndpoints.profileBirth,
        body: requestModel.toJson(),
      );
      final Map<String, dynamic> responseData = decodeResponse(response);

      return ApiResponseModel<void>.fromJson(
        responseData,
        (Map<String, dynamic> json) {},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 성별 수정
  Future<ApiResponseModel<void>> updateGender(String gender) async {
    try {
      final ProfileUpdateRequestModel requestModel = ProfileUpdateRequestModel(
        value: gender,
      );

      final http.Response response = await put(
        ApiEndpoints.userGender,
        body: requestModel.toJson(),
      );
      final Map<String, dynamic> responseData = decodeResponse(response);

      return ApiResponseModel<void>.fromJson(
        responseData,
        (Map<String, dynamic> json) {},
      );
    } catch (e) {
      rethrow;
    }
  }
}
