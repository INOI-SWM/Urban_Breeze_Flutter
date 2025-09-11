import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';

class User {
  const User({
    required this.uuid,
    required this.nickname,
    required this.email,
    this.profileImagePath,
    this.introduce,
    this.birthYear,
    this.gender,
    this.displayName,
    required this.loginProvider,
    this.isFirstLogin = false,
  });

  final String uuid;
  final String nickname;
  final String email;
  final String? profileImagePath;
  final String? introduce;
  final int? birthYear;
  final String? gender;
  final String? displayName;
  final LoginProvider loginProvider;
  final bool isFirstLogin;

  User copyWith({
    String? uuid,
    String? nickname,
    String? email,
    String? profileImagePath,
    String? introduce,
    int? birthYear,
    String? gender,
    String? displayName,
    LoginProvider? loginProvider,
    bool? isFirstLogin,
  }) {
    return User(
      uuid: uuid ?? this.uuid,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      introduce: introduce ?? this.introduce,
      birthYear: birthYear ?? this.birthYear,
      gender: gender ?? this.gender,
      displayName: displayName ?? this.displayName,
      loginProvider: loginProvider ?? this.loginProvider,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.uuid == uuid &&
        other.nickname == nickname &&
        other.email == email &&
        other.profileImagePath == profileImagePath &&
        other.introduce == introduce &&
        other.birthYear == birthYear &&
        other.gender == gender &&
        other.displayName == displayName &&
        other.loginProvider == loginProvider &&
        other.isFirstLogin == isFirstLogin;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        nickname.hashCode ^
        email.hashCode ^
        profileImagePath.hashCode ^
        introduce.hashCode ^
        birthYear.hashCode ^
        gender.hashCode ^
        displayName.hashCode ^
        loginProvider.hashCode ^
        isFirstLogin.hashCode;
  }

  @override
  String toString() {
    return 'User(uuid: $uuid, nickname: $nickname, email: $email, profileImagePath: $profileImagePath, introduce: $introduce, birthYear: $birthYear, gender: $gender, displayName: $displayName, loginProvider: $loginProvider, isFirstLogin: $isFirstLogin)';
  }
}
