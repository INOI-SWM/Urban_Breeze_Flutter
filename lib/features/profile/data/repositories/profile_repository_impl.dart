import 'package:urban_breeze/features/profile/data/models/profile_model.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';
import '../datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required ProfileDataSource dataSource,
    required ProfileLocalDataSource localDataSource,
  }) : _dataSource = dataSource,
       _localDataSource = localDataSource;

  final ProfileDataSource _dataSource;
  final ProfileLocalDataSource _localDataSource;

  @override
  Future<Profile> getProfile() async {
    final ApiResponseModel<ProfileModel> response =
        await _dataSource.getProfile();
    final Profile profile = response.data.toEntity();

    // 로컬에 저장
    await _localDataSource.saveProfile(profile);

    return profile;
  }

  @override
  Future<Profile> updateNickname(String nickname) async {
    final ApiResponseModel<ProfileModel> response = await _dataSource
        .updateNickname(nickname);
    final Profile updatedProfile = response.data.toEntity();

    // 로컬에 저장
    await _localDataSource.updateNickname(nickname);

    return updatedProfile;
  }

  @override
  Future<Profile> updateIntroduce(String introduce) async {
    final ApiResponseModel<ProfileModel> response = await _dataSource
        .updateIntroduce(introduce);
    final Profile updatedProfile = response.data.toEntity();

    // 로컬에 저장
    await _localDataSource.updateIntroduce(introduce);

    return updatedProfile;
  }

  @override
  Future<Profile> updateBirth(String birth) async {
    final ApiResponseModel<ProfileModel> response = await _dataSource
        .updateBirth(birth);
    final Profile updatedProfile = response.data.toEntity();

    // 로컬에 저장
    await _localDataSource.updateBirth(birth);

    return updatedProfile;
  }

  @override
  Future<Profile> updateGender(String gender) async {
    final ApiResponseModel<ProfileModel> response = await _dataSource
        .updateGender(gender);
    final Profile updatedProfile = response.data.toEntity();

    // 로컬에 저장
    await _localDataSource.updateGender(gender);

    return updatedProfile;
  }
}
