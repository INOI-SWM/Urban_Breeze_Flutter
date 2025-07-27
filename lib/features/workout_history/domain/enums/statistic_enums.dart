enum StatisticPeriodType {
  week,
  month,
  year,
  all;

  String get label {
    switch (this) {
      case StatisticPeriodType.week:
        return '주';
      case StatisticPeriodType.month:
        return '월';
      case StatisticPeriodType.year:
        return '년';
      case StatisticPeriodType.all:
        return '전체';
    }
  }

  String get apiValue {
    switch (this) {
      case StatisticPeriodType.week:
        return 'week';
      case StatisticPeriodType.month:
        return 'month';
      case StatisticPeriodType.year:
        return 'year';
      case StatisticPeriodType.all:
        return 'all';
    }
  }
}

enum StaticDataType {
  distance,
  elevation,
  duration;

  String get label {
    switch (this) {
      case StaticDataType.distance:
        return '거리';
      case StaticDataType.elevation:
        return '상승 고도';
      case StaticDataType.duration:
        return '시간';
    }
  }
}
