import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
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
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      nickname: json['nickname'] as String? ?? '',
      introduce: json['introduce'] as String?,
      birth: json['birth'] as String?,
      gender: json['gender'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nickname': nickname,
      'introduce': introduce,
      'birth': birth,
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
