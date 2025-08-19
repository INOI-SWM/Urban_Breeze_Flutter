enum CourseSortType {
  nearest('가까운 순'),
  distanceLong('거리 긴 순'),
  distanceShort('거리 짧은 순'),
  difficultyHigh('난이도 높은 순'),
  difficultyLow('난이도 낮은 순');

  const CourseSortType(this.displayName);
  final String displayName;

  /// API에서 사용하는 정렬 타입 문자열 반환
  String get apiValue {
    switch (this) {
      case CourseSortType.nearest:
        return 'NEAREST';
      case CourseSortType.distanceLong:
        return 'DISTANCE_LONG';
      case CourseSortType.distanceShort:
        return 'DISTANCE_SHORT';
      case CourseSortType.difficultyHigh:
        return 'DIFFICULTY_HIGH';
      case CourseSortType.difficultyLow:
        return 'DIFFICULTY_LOW';
    }
  }
}
