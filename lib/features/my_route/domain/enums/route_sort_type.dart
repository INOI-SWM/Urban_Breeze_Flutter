enum RouteSortType {
  newest('최근 생성 순'),
  oldest('생성 오래된 순'),
  nearest('가까운 순'),
  distanceLong('거리 긴 순'),
  distanceShort('거리 짧은 순');

  const RouteSortType(this.displayName);
  final String displayName;
}
