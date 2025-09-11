import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uuid: json['uuid'] as String?,
      nickname: json['nickname'] as String? ?? '',
      email: json['email'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
      introduce: json['introduce'] as String?,
      birth: json['birthYear']?.toString(), // int를 String으로 변환
      gender: json['gender'] as String?,
    );
  }

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      nickname: profile.nickname,
      introduce: profile.introduce,
      birth: profile.birth,
      gender: profile.gender,
    );
  }
  const ProfileModel({
    required super.nickname,
    super.introduce,
    super.birth,
    super.gender,
    this.uuid,
    this.email,
    this.profileImagePath,
  });

  final String? uuid;
  final String? email;
  final String? profileImagePath;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uuid': uuid,
      'nickname': nickname,
      'email': email,
      'profileImagePath': profileImagePath,
      'introduce': introduce,
      'birthYear': birth != null ? int.tryParse(birth!) : null,
      'gender': gender,
    };
  }

  Profile toEntity() {
    return Profile(
      nickname: nickname,
      introduce: introduce,
      birth: birth,
      gender: gender,
    );
  }
}
