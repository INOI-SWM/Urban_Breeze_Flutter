import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';

class ProfileModel {
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uuid: json['uuid'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImagePath: json['profileImagePath'] as String?,
      introduce: json['introduce'] as String?,
      birthYear: json['birthYear'] as int?,
      gender: json['gender'] as String?,
      displayName: json['displayName'] as String?,
      loginProvider: LoginProviderExtension.fromJson(
        json['loginProvider'] as String? ?? '',
      ),
      isFirstLogin: json['isFirstLogin'] as bool? ?? false,
    );
  }

  const ProfileModel({
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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uuid': uuid,
      'nickname': nickname,
      'email': email,
      'profileImagePath': profileImagePath,
      'introduce': introduce,
      'birthYear': birthYear,
      'gender': gender,
      'displayName': displayName,
      'loginProvider': loginProvider.name,
      'isFirstLogin': isFirstLogin,
    };
  }

  User toUser() {
    return User(
      uuid: uuid,
      nickname: nickname,
      email: email,
      profileImagePath: profileImagePath,
      introduce: introduce,
      birthYear: birthYear,
      gender: gender,
      displayName: displayName,
      loginProvider: loginProvider,
      isFirstLogin: isFirstLogin,
    );
  }
}
