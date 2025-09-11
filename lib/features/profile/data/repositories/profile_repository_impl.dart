import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/data/models/profile_model.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

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
  Future<User> getProfile() async {
    final ApiResponseModel<ProfileModel> response =
        await _dataSource.getProfile();
    final User user = response.data.toUser();

    // 로컬에 저장
    await _localDataSource.saveProfile(user);

    return user;
  }

  @override
  Future<User> updateNickname(String nickname) async {
    final ApiResponseModel<ProfileModel> response = await _dataSource
        .updateNickname(nickname);
    final User updatedUser = response.data.toUser();

    // 로컬에 저장
    await _localDataSource.updateNickname(nickname);

    return updatedUser;
  }

  @override
  Future<User> updateIntroduce(String introduce) async {
    final ApiResponseModel<ProfileModel> response = await _dataSource
        .updateIntroduce(introduce);
    final User updatedUser = response.data.toUser();

    // 로컬에 저장
    await _localDataSource.updateIntroduce(introduce);

    return updatedUser;
  }

  @override
  Future<User> updateBirth(String birth) async {
    final ApiResponseModel<ProfileModel> response = await _dataSource
        .updateBirth(birth);
    final User updatedUser = response.data.toUser();

    // 로컬에 저장
    await _localDataSource.updateBirth(birth);

    return updatedUser;
  }

  @override
  Future<User> updateGender(String gender) async {
    final ApiResponseModel<ProfileModel> response = await _dataSource
        .updateGender(gender);
    final User updatedUser = response.data.toUser();

    // 로컬에 저장
    await _localDataSource.updateGender(gender);

    return updatedUser;
  }
}
