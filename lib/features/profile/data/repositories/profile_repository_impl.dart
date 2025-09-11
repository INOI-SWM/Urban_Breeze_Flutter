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

  @override
  Future<User> getProfile() async {
    final User? currentUser = await _userSessionRepository.loadUser();
    final LoginProvider? loginProvider = currentUser?.loginProvider;

    if (loginProvider == null) {
      throw Exception('Current user login provider not found');
    }

    final ApiResponseModel<User> response = await _dataSource.getProfile(
      loginProvider,
    );
    final User user = response.data;

    _validateUser(user);

    await _userSessionRepository.saveUser(user);

    return user;
  }

  @override
  Future<User> updateNickname(String nickname) async {
    _validateNickname(nickname);

    final User? currentUser = await _userSessionRepository.loadUser();
    final LoginProvider? loginProvider = currentUser?.loginProvider;

    if (loginProvider == null) {
      throw Exception('Current user login provider not found');
    }

    final ApiResponseModel<User> response = await _dataSource.updateNickname(
      nickname,
      loginProvider,
    );
    final User user = response.data;

    _validateUser(user);

    await _userSessionRepository.saveUser(user);

    return user;
  }

  @override
  Future<User> updateIntroduce(String introduce) async {
    _validateIntroduce(introduce);

    final User? currentUser = await _userSessionRepository.loadUser();
    final LoginProvider? loginProvider = currentUser?.loginProvider;

    if (loginProvider == null) {
      throw Exception('Current user login provider not found');
    }

    final ApiResponseModel<User> response = await _dataSource.updateIntroduce(
      introduce,
      loginProvider,
    );
    final User user = response.data;

    _validateUser(user);

    await _userSessionRepository.saveUser(user);

    return user;
  }

  @override
  Future<User> updateBirth(String birth) async {
    _validateBirth(birth);

    final User? currentUser = await _userSessionRepository.loadUser();
    final LoginProvider? loginProvider = currentUser?.loginProvider;

    if (loginProvider == null) {
      throw Exception('Current user login provider not found');
    }

    final ApiResponseModel<User> response = await _dataSource.updateBirth(
      birth,
      loginProvider,
    );
    final User user = response.data;

    _validateUser(user);

    await _userSessionRepository.saveUser(user);

    return user;
  }

  @override
  Future<User> updateGender(String gender) async {
    _validateGender(gender);

    final User? currentUser = await _userSessionRepository.loadUser();
    final LoginProvider? loginProvider = currentUser?.loginProvider;

    if (loginProvider == null) {
      throw Exception('Current user login provider not found');
    }

    final ApiResponseModel<User> response = await _dataSource.updateGender(
      gender,
      loginProvider,
    );
    final User user = response.data;

    _validateUser(user);

    await _userSessionRepository.saveUser(user);

    return user;
  }

  void _validateUser(User user) {
    if (user.uuid.isEmpty) {
      throw Exception('User UUID cannot be empty');
    }
    if (user.nickname.isEmpty) {
      throw Exception('User nickname cannot be empty');
    }
  }

  void _validateNickname(String nickname) {
    if (nickname.isEmpty) {
      throw Exception('Nickname cannot be empty');
    }
    if (nickname.length > 20) {
      throw Exception('Nickname cannot exceed 20 characters');
    }
  }

  void _validateIntroduce(String introduce) {
    if (introduce.length > 200) {
      throw Exception('Introduce cannot exceed 200 characters');
    }
  }

  void _validateBirth(String birth) {
    final int? birthYear = int.tryParse(birth);
    if (birthYear == null) {
      throw Exception('Birth year must be a valid number');
    }
    final int currentYear = DateTime.now().year;
    if (birthYear < 1900 || birthYear > currentYear) {
      throw Exception('Birth year must be between 1900 and $currentYear');
    }
  }

  void _validateGender(String gender) {
    final List<String> validGenders = <String>['MALE', 'FEMALE', 'OTHER'];
    if (!validGenders.contains(gender.toUpperCase())) {
      throw Exception('Gender must be MALE, FEMALE, or OTHER');
    }
  }
}
