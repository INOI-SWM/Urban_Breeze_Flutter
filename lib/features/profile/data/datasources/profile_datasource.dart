import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';
import 'package:urban_breeze/features/auth/domain/repositories/user_session_repository.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class ProfileDataSource extends BaseRemoteDataSource {
  ProfileDataSource({
    super.client,
    required UserSessionRepository userSessionRepository,
  }) : _userSessionRepository = userSessionRepository;

  final UserSessionRepository _userSessionRepository;

  /// 현재 사용자의 loginProvider를 가져와서 User 객체를 생성하는 공통 메서드
  Future<ApiResponseModel<User>> _createUserResponse(
    Map<String, dynamic> responseData,
  ) async {
    // 현재 사용자의 loginProvider 가져오기
    final User? currentUser = await _userSessionRepository.loadUser();
    final LoginProvider? loginProvider = currentUser?.loginProvider;

    if (loginProvider == null) {
      throw Exception('Current user login provider not found');
    }

    return ApiResponseModel<User>.fromJson(
      responseData,
      (Map<String, dynamic> json) =>
          User.fromJsonForProfile(json, loginProvider),
    );
  }

  /// 프로필 정보 조회
  Future<ApiResponseModel<User>> getProfile() async {
    try {
      final http.Response response = await get(ApiEndpoints.profile);
      final Map<String, dynamic> responseData = decodeResponse(response);
      return await _createUserResponse(responseData);
    } catch (e) {
      rethrow;
    }
  }

  /// 닉네임 수정
  Future<ApiResponseModel<User>> updateNickname(String nickname) async {
    try {
      final http.Response response = await put(
        ApiEndpoints.profileNickname,
        body: <String, String>{'nickname': nickname},
      );
      final Map<String, dynamic> responseData = decodeResponse(response);
      return await _createUserResponse(responseData);
    } catch (e) {
      rethrow;
    }
  }

  /// 자기소개 수정
  Future<ApiResponseModel<User>> updateIntroduce(String introduce) async {
    try {
      final http.Response response = await put(
        ApiEndpoints.profileIntroduce,
        body: <String, String>{'introduce': introduce},
      );
      final Map<String, dynamic> responseData = decodeResponse(response);
      return await _createUserResponse(responseData);
    } catch (e) {
      rethrow;
    }
  }

  /// 생년월일 수정
  Future<ApiResponseModel<User>> updateBirth(String birth) async {
    try {
      final http.Response response = await put(
        ApiEndpoints.profileBirth,
        body: <String, String>{'birthYear': birth},
      );
      final Map<String, dynamic> responseData = decodeResponse(response);
      return await _createUserResponse(responseData);
    } catch (e) {
      rethrow;
    }
  }

  /// 성별 수정
  Future<ApiResponseModel<User>> updateGender(String gender) async {
    try {
      final http.Response response = await put(
        ApiEndpoints.userGender,
        body: <String, String>{'gender': gender},
      );
      final Map<String, dynamic> responseData = decodeResponse(response);
      debugPrint('responseData: $responseData');
      return await _createUserResponse(responseData);
    } catch (e) {
      rethrow;
    }
  }
}
