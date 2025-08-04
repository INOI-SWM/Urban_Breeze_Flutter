enum WorkoutSortType {
  newest('최신순'),
  oldest('오래된 순'),
  distance('거리순');

  const WorkoutSortType(this.displayName);
  final String displayName;
}
