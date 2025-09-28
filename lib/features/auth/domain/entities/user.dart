import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';

class User {
  /// JSON에서 User 객체 생성 (로그인 시 사용)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uuid: json['uuid'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      introduce: json['introduce'] as String?,
      birthYear: json['birthYear'] as int?,
      gender: json['gender'] as String?,
      displayName: json['displayName'] as String?,
      loginProvider: LoginProviderExtension.fromJson(
        json['loginProvider'] as String? ?? '',
      ),
    );
  }

  /// JSON에서 User 객체 생성 (프로필 업데이트 시 사용 - loginProvider 제외)
  factory User.fromJsonForProfile(
    Map<String, dynamic> json,
    LoginProvider loginProvider,
  ) {
    return User(
      uuid: json['uuid'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      introduce: json['introduce'] as String?,
      birthYear: json['birthYear'] as int?,
      gender: json['gender'] as String?,
      displayName: json['displayName'] as String?,
      loginProvider: loginProvider, // 기존 loginProvider 유지
    );
  }
  const User({
    required this.uuid,
    required this.nickname,
    required this.email,
    this.profileImageUrl,
    this.introduce,
    this.birthYear,
    this.gender,
    this.displayName,
    required this.loginProvider,
  });

  final String uuid;
  final String nickname;
  final String email;
  final String? profileImageUrl;
  final String? introduce;
  final int? birthYear;
  final String? gender;
  final String? displayName;
  final LoginProvider loginProvider;

  User copyWith({
    String? uuid,
    String? nickname,
    String? email,
    String? profileImageUrl,
    String? introduce,
    int? birthYear,
    String? gender,
    String? displayName,
    LoginProvider? loginProvider,
  }) {
    return User(
      uuid: uuid ?? this.uuid,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      introduce: introduce ?? this.introduce,
      birthYear: birthYear ?? this.birthYear,
      gender: gender ?? this.gender,
      displayName: displayName ?? this.displayName,
      loginProvider: loginProvider ?? this.loginProvider,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.uuid == uuid &&
        other.nickname == nickname &&
        other.email == email &&
        other.profileImageUrl == profileImageUrl &&
        other.introduce == introduce &&
        other.birthYear == birthYear &&
        other.gender == gender &&
        other.displayName == displayName &&
        other.loginProvider == loginProvider;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        nickname.hashCode ^
        email.hashCode ^
        profileImageUrl.hashCode ^
        introduce.hashCode ^
        birthYear.hashCode ^
        gender.hashCode ^
        displayName.hashCode ^
        loginProvider.hashCode;
  }

  @override
  String toString() {
    return 'User(uuid: $uuid, nickname: $nickname, email: $email, profileImageUrl: $profileImageUrl, introduce: $introduce, birthYear: $birthYear, gender: $gender, displayName: $displayName, loginProvider: $loginProvider)';
  }

  /// User 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uuid': uuid,
      'nickname': nickname,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'introduce': introduce,
      'birthYear': birthYear,
      'gender': gender,
      'displayName': displayName,
      'loginProvider': loginProvider.name,
    };
  }
}
