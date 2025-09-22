class WorkoutUser {
  const WorkoutUser({
    required this.uuid,
    required this.nickname,
    required this.profileImageUrl,
  });

  final String uuid;
  final String nickname;
  final String profileImageUrl;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutUser && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() {
    return 'WorkoutUser(uuid: $uuid, nickname: $nickname)';
  }
}
