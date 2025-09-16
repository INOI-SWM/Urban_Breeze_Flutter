import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';
import 'package:urban_breeze/features/auth/domain/repositories/user_session_repository.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required ProfileDataSource dataSource,
    required UserSessionRepository userSessionRepository,
  }) : _dataSource = dataSource,
       _userSessionRepository = userSessionRepository;

  final ProfileDataSource _dataSource;
  final UserSessionRepository _userSessionRepository;

  /// 공통 업데이트 로직을 처리하는 헬퍼 메서드
  Future<User> _executeUpdate(
    Future<ApiResponseModel<User>> Function(LoginProvider) updateFunction,
  ) async {
    final User? currentUser = await _userSessionRepository.loadUser();
    final LoginProvider? loginProvider = currentUser?.loginProvider;

    if (loginProvider == null) {
      throw Exception('Current user login provider not found');
    }

    final ApiResponseModel<User> response = await updateFunction(loginProvider);
    final User user = response.data;

    _validateUser(user);
    await _userSessionRepository.saveUser(user);
    return user;
  }

  @override
  Future<User> getProfile() async {
    return _executeUpdate(
      (LoginProvider loginProvider) => _dataSource.getProfile(loginProvider),
    );
  }

  @override
  Future<User> updateNickname(String nickname) async {
    return _executeUpdate(
      (LoginProvider loginProvider) =>
          _dataSource.updateNickname(nickname, loginProvider),
    );
  }

  @override
  Future<User> updateIntroduce(String introduce) async {
    return _executeUpdate(
      (LoginProvider loginProvider) =>
          _dataSource.updateIntroduce(introduce, loginProvider),
    );
  }

  @override
  Future<User> updateBirth(String birth) async {
    return _executeUpdate(
      (LoginProvider loginProvider) =>
          _dataSource.updateBirth(birth, loginProvider),
    );
  }

  @override
  Future<User> updateGender(String gender) async {
    return _executeUpdate(
      (LoginProvider loginProvider) =>
          _dataSource.updateGender(gender, loginProvider),
    );
  }

  void _validateUser(User user) {
    if (user.uuid.isEmpty) {
      throw Exception('User UUID cannot be empty');
    }
    if (user.nickname.isEmpty) {
      throw Exception('User nickname cannot be empty');
    }
  }

  @override
  Future<User> updateProfileImagePath(String profileImagePath) async {
    return _executeUpdate(
      (LoginProvider loginProvider) =>
          _dataSource.updateProfileImagePath(profileImagePath, loginProvider),
    );
  }
}
