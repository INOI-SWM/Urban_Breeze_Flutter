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
  Future<void> updateNickname(String nickname) async {
    await _dataSource.updateNickname(nickname);
  }

  @override
  Future<void> updateIntroduce(String introduce) async {
    await _dataSource.updateIntroduce(introduce);
  }

  @override
  Future<void> updateBirth(String birth) async {
    await _dataSource.updateBirth(birth);
  }

  @override
  Future<void> updateGender(String gender) async {
    await _dataSource.updateGender(gender);
  }
}
