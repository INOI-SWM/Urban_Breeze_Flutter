class ChartAxisUtils {
  ChartAxisUtils._();

  /// 데이터 범위에 따른 적절한 Y축 간격 계산
  ///
  /// [range]: 데이터의 최댓값 - 최솟값
  /// [maxValue]: 최댓값 (선택적, 더 정교한 계산을 위해)
  static double calculateInterval(double range, {double? maxValue}) {
    if (range < 10) return 2;
    if (range < 20) return 5;
    if (range < 50) return 10;
    if (range < 100) return 20;

    if (maxValue != null) {
      if (maxValue <= 10) return 2;
      if (maxValue <= 50) return 10;
      if (maxValue <= 100) return 20;
      if (maxValue <= 500) return 100;
      if (maxValue <= 1000) return 200;
      if (maxValue <= 5000) return 1000;
      if (maxValue <= 10000) return 2000;
      if (maxValue <= 50000) return 10000;

      // 매우 큰 값들은 적절한 10의 배수로 설정
      final double baseInterval = (maxValue / 5).roundToDouble();
      if (baseInterval >= 10000) {
        return (baseInterval / 10000).round() * 10000.0;
      } else if (baseInterval >= 1000) {
        return (baseInterval / 1000).round() * 1000.0;
      } else if (baseInterval >= 100) {
        return (baseInterval / 100).round() * 100.0;
      }
      return baseInterval;
    }

    return 20;
  }

  /// 차트 Y축 최솟값 계산
  ///
  /// [minValue]: 데이터의 최솟값
  /// [interval]: 축 간격
  static double calculateChartMinY(double minValue, double interval) {
    return ((minValue / interval).floor()) * interval;
  }

  /// 차트 Y축 최댓값 계산
  ///
  /// [maxValue]: 데이터의 최댓값
  /// [interval]: 축 간격
  /// [topPaddingRatio]: 상단 여유 공간 비율 (기본 0.1)
  static double calculateChartMaxY(
    double maxValue,
    double interval, {
    double topPaddingRatio = 0.1,
  }) {
    return ((maxValue / interval).ceil()) * interval +
        (interval * topPaddingRatio);
  }

  static double getMinValue<T>(
    List<T> data,
    double Function(T) valueExtractor,
  ) {
    if (data.isEmpty) throw ArgumentError('Data list cannot be empty');
    return data
        .map(valueExtractor)
        .reduce((double a, double b) => a < b ? a : b);
  }

  static double getMaxValue<T>(
    List<T> data,
    double Function(T) valueExtractor,
  ) {
    if (data.isEmpty) throw ArgumentError('Data list cannot be empty');
    return data
        .map(valueExtractor)
        .reduce((double a, double b) => a > b ? a : b);
  }
}
