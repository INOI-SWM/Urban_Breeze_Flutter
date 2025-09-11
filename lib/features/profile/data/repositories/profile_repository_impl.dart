import 'package:urban_breeze/features/profile/data/models/profile_model.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required ProfileDataSource dataSource})
    : _dataSource = dataSource;

  final ProfileDataSource _dataSource;

  @override
  Future<Profile> getProfile() async {
    final ApiResponseModel<ProfileModel> response =
        await _dataSource.getProfile();
    return response.data.toEntity();
  }

  @override
  Future<Profile> updateNickname(String nickname) async {
    final ApiResponseModel<ProfileModel> response = await _dataSource
        .updateNickname(nickname);
    return response.data.toEntity();
  }

  @override
  Future<Profile> updateIntroduce(String introduce) async {
    final ApiResponseModel<ProfileModel> response = await _dataSource
        .updateIntroduce(introduce);
    return response.data.toEntity();
  }

  @override
  Future<Profile> updateBirth(String birth) async {
    final ApiResponseModel<ProfileModel> response = await _dataSource
        .updateBirth(birth);
    return response.data.toEntity();
  }

  @override
  Future<Profile> updateGender(String gender) async {
    final ApiResponseModel<ProfileModel> response = await _dataSource
        .updateGender(gender);
    return response.data.toEntity();
  }
}
