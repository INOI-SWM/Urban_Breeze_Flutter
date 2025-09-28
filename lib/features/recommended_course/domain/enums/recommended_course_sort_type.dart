/// 추천 코스 정렬 타입
enum RecommendedCourseSortType {
  nearest('NEAREST', '가까운 순'),
  distanceLong('DISTANCE_LONG', '거리 긴 순'),
  distanceShort('DISTANCE_SHORT', '거리 짧은 순'),
  difficultyHigh('DIFFICULTY_HIGH', '난이도 높은 순'),
  difficultyLow('DIFFICULTY_LOW', '난이도 낮은 순');

  const RecommendedCourseSortType(this.apiValue, this.displayName);

  final String apiValue;
  final String displayName;
}
