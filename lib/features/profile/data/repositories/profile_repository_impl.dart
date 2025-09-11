import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required ProfileDataSource dataSource})
    : _dataSource = dataSource;

  final ProfileDataSource _dataSource;

  @override
  Future<User> getProfile() async {
    final ApiResponseModel<User> response = await _dataSource.getProfile();
    return response.data;
  }

  @override
  Future<User> updateNickname(String nickname) async {
    final ApiResponseModel<User> response = await _dataSource.updateNickname(
      nickname,
    );
    return response.data;
  }

  @override
  Future<User> updateIntroduce(String introduce) async {
    final ApiResponseModel<User> response = await _dataSource.updateIntroduce(
      introduce,
    );
    return response.data;
  }

  @override
  Future<User> updateBirth(String birth) async {
    final ApiResponseModel<User> response = await _dataSource.updateBirth(
      birth,
    );
    return response.data;
  }

  @override
  Future<User> updateGender(String gender) async {
    final ApiResponseModel<User> response = await _dataSource.updateGender(
      gender,
    );
    return response.data;
  }
}
