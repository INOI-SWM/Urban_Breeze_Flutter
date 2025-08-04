enum CourseSortType {
  newest('가까운 순'),
  oldest('거리 긴 순'),
  nearest('거리 짧은 순'),
  distanceLong('난이도 높은 순'),
  distanceShort('난이도 짧은 순');

  const CourseSortType(this.displayName);
  final String displayName;
}
