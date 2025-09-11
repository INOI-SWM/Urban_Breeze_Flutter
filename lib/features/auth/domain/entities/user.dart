import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';

class User {
  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.loginProvider,
    this.isFirstLogin = false,
    this.uuid,
    this.nickname,
    this.introduce,
    this.birth,
    this.gender,
    this.profileImagePath,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final LoginProvider loginProvider;
  final bool isFirstLogin;

  // 프로필 정보
  final String? uuid;
  final String? nickname;
  final String? introduce;
  final String? birth;
  final String? gender;
  final String? profileImagePath;

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    LoginProvider? loginProvider,
    bool? isFirstLogin,
    String? uuid,
    String? nickname,
    String? introduce,
    String? birth,
    String? gender,
    String? profileImagePath,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      loginProvider: loginProvider ?? this.loginProvider,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      uuid: uuid ?? this.uuid,
      nickname: nickname ?? this.nickname,
      introduce: introduce ?? this.introduce,
      birth: birth ?? this.birth,
      gender: gender ?? this.gender,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
