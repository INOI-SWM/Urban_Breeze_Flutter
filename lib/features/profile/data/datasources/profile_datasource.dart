import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';
import 'package:urban_breeze/shared/utils/image_upload_utils.dart';

class ProfileDataSource extends BaseRemoteDataSource {
  ProfileDataSource({super.client});

  /// loginProvider를 받아서 User 객체를 생성하는 공통 메서드
  ApiResponseModel<User> _createUserResponse(
    Map<String, dynamic> responseData,
    LoginProvider loginProvider,
  ) {
    return ApiResponseModel<User>.fromJson(
      responseData,
      (Map<String, dynamic> json) =>
          User.fromJsonForProfile(json, loginProvider),
    );
  }

  /// 프로필 정보 조회
  Future<ApiResponseModel<User>> getProfile(LoginProvider loginProvider) async {
    try {
      final http.Response response = await get(ApiEndpoints.profile);
      final Map<String, dynamic> responseData = decodeResponse(response);
      return _createUserResponse(responseData, loginProvider);
    } catch (e) {
      rethrow;
    }
  }

  /// 닉네임 수정
  Future<ApiResponseModel<User>> updateNickname(
    String nickname,
    LoginProvider loginProvider,
  ) async {
    try {
      final http.Response response = await put(
        ApiEndpoints.profileNickname,
        body: <String, String>{'nickname': nickname},
      );
      final Map<String, dynamic> responseData = decodeResponse(response);
      return _createUserResponse(responseData, loginProvider);
    } catch (e) {
      rethrow;
    }
  }

  /// 자기소개 수정
  Future<ApiResponseModel<User>> updateIntroduce(
    String introduce,
    LoginProvider loginProvider,
  ) async {
    try {
      final http.Response response = await put(
        ApiEndpoints.profileIntroduce,
        body: <String, String>{'introduce': introduce},
      );
      final Map<String, dynamic> responseData = decodeResponse(response);
      return _createUserResponse(responseData, loginProvider);
    } catch (e) {
      rethrow;
    }
  }

  /// 생년월일 수정
  Future<ApiResponseModel<User>> updateBirth(
    String birth,
    LoginProvider loginProvider,
  ) async {
    try {
      final http.Response response = await put(
        ApiEndpoints.profileBirth,
        body: <String, String>{'birthYear': birth},
      );
      final Map<String, dynamic> responseData = decodeResponse(response);
      return _createUserResponse(responseData, loginProvider);
    } catch (e) {
      rethrow;
    }
  }

  /// 성별 수정
  Future<ApiResponseModel<User>> updateGender(
    String gender,
    LoginProvider loginProvider,
  ) async {
    try {
      final http.Response response = await put(
        ApiEndpoints.userGender,
        body: <String, String>{'gender': gender},
      );
      final Map<String, dynamic> responseData = decodeResponse(response);
      debugPrint('responseData: $responseData');
      return _createUserResponse(responseData, loginProvider);
    } catch (e) {
      rethrow;
    }
  }

  /// 프로필 이미지 업로드
  Future<ApiResponseModel<User>> uploadProfileImage(
    File imageFile,
    LoginProvider loginProvider,
  ) async {
    try {
      // ImageUploadUtils를 사용하여 MultipartFile 생성
      final http.MultipartFile multipartFile =
          await ImageUploadUtils.createImageMultipartFile(
            imageFile,
            'profileImage',
            maxSizeInMB: 20,
          );

      final http.StreamedResponse response = await putMultipart(
        ApiEndpoints.profileImagePath,
        fields: <String, String>{},
        files: <String, http.MultipartFile>{'profileImage': multipartFile},
      );

      // StreamedResponse를 Response로 변환
      final http.Response responseConverted = await http.Response.fromStream(
        response,
      );

      final Map<String, dynamic> responseData = decodeResponse(
        responseConverted,
      );

      return _createUserResponse(responseData, loginProvider);
    } catch (e) {
      rethrow;
    }
  }
}
