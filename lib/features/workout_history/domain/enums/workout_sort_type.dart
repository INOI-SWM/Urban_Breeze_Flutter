enum WorkoutSortType {
  startedAtDesc('최신순'),
  startedAtAsc('오래된순'),
  distanceAsc('주행거리 오름차순'),
  distanceDesc('주행거리 내림차순');

  const WorkoutSortType(this.displayName);
  final String displayName;

  String get apiValue {
    switch (this) {
      case WorkoutSortType.startedAtDesc:
        return 'STARTED_AT_DESC';
      case WorkoutSortType.startedAtAsc:
        return 'STARTED_AT_ASC';
      case WorkoutSortType.distanceAsc:
        return 'DISTANCE_ASC';
      case WorkoutSortType.distanceDesc:
        return 'DISTANCE_DESC';
    }
  }
}
