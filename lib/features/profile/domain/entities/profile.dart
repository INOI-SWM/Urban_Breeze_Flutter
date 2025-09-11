class Profile {
  const Profile({
    required this.nickname,
    this.introduce,
    this.birth,
    this.gender,
  });

  final String nickname;
  final String? introduce;
  final String? birth;
  final String? gender;

  Profile copyWith({
    String? nickname,
    String? introduce,
    String? birth,
    String? gender,
  }) {
    return Profile(
      nickname: nickname ?? this.nickname,
      introduce: introduce ?? this.introduce,
      birth: birth ?? this.birth,
      gender: gender ?? this.gender,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile &&
        other.nickname == nickname &&
        other.introduce == introduce &&
        other.birth == birth &&
        other.gender == gender;
  }

  @override
  int get hashCode {
    return nickname.hashCode ^
        introduce.hashCode ^
        birth.hashCode ^
        gender.hashCode;
  }

  @override
  String toString() {
    return 'Profile(nickname: $nickname, introduce: $introduce, birth: $birth, gender: $gender)';
  }
}
