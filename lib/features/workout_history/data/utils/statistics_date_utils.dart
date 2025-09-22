import '../../domain/enums/statistic_enums.dart';

/// 통계 API를 위한 날짜 계산 유틸리티
class StatisticsDateUtils {
  /// PeriodSelection과 기간 타입으로부터 startDate, endDate를 계산합니다.
  static DateRange calculateDateRange({
    required StatisticPeriodType periodType,
    required int year,
    int? month,
    int? week,
  }) {
    switch (periodType) {
      case StatisticPeriodType.week:
        return _calculateWeekRange(year, month!, week!);
      case StatisticPeriodType.month:
        return _calculateMonthRange(year, month!);
      case StatisticPeriodType.year:
        return _calculateYearRange(year);
      case StatisticPeriodType.all:
        // 전체 기간은 서버에서 처리하므로 null 반환
        return const DateRange(startDate: null, endDate: null);
    }
  }

  /// 주간 날짜 범위 계산
  static DateRange _calculateWeekRange(int year, int month, int week) {
    // 해당 월의 첫 번째 날
    final DateTime firstDayOfMonth = DateTime(year, month, 1);

    // 월의 첫 번째 월요일 찾기
    final int firstMondayOffset =
        (DateTime.monday - firstDayOfMonth.weekday + 7) % 7;
    final DateTime firstMonday = firstDayOfMonth.add(
      Duration(days: firstMondayOffset),
    );

    // N번째 주의 시작일과 종료일 계산
    final DateTime weekStart = firstMonday.add(Duration(days: (week - 1) * 7));
    final DateTime weekEnd = weekStart.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    // 해당 월 범위를 벗어나지 않도록 조정
    final DateTime monthEnd = DateTime(year, month + 1, 0, 23, 59, 59);
    final DateTime adjustedStart =
        weekStart.isBefore(firstDayOfMonth) ? firstDayOfMonth : weekStart;
    final DateTime adjustedEnd = weekEnd.isAfter(monthEnd) ? monthEnd : weekEnd;

    return DateRange(startDate: adjustedStart, endDate: adjustedEnd);
  }

  /// 월간 날짜 범위 계산
  static DateRange _calculateMonthRange(int year, int month) {
    final DateTime startDate = DateTime(year, month, 1);
    final DateTime endDate = DateTime(
      year,
      month + 1,
      0,
      23,
      59,
      59,
    ); // 해당 월의 마지막 날

    return DateRange(startDate: startDate, endDate: endDate);
  }

  /// 연간 날짜 범위 계산
  static DateRange _calculateYearRange(int year) {
    final DateTime startDate = DateTime(year, 1, 1);
    final DateTime endDate = DateTime(year, 12, 31, 23, 59, 59);

    return DateRange(startDate: startDate, endDate: endDate);
  }

  /// API 파라미터 형식으로 변환 (YYYY-MM-DD)
  static String formatDateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// 기간 타입을 API 파라미터 형식으로 변환
  static String periodTypeToApiParam(StatisticPeriodType periodType) {
    switch (periodType) {
      case StatisticPeriodType.week:
        return 'WEEK';
      case StatisticPeriodType.month:
        return 'MONTH';
      case StatisticPeriodType.year:
        return 'YEAR';
      case StatisticPeriodType.all:
        return 'ALL';
    }
  }
}

/// 날짜 범위를 나타내는 클래스
class DateRange {
  const DateRange({required this.startDate, required this.endDate});

  final DateTime? startDate;
  final DateTime? endDate;

  /// API 쿼리 파라미터로 변환
  Map<String, String> toApiParams(StatisticPeriodType periodType) {
    final Map<String, String> params = <String, String>{
      'period': StatisticsDateUtils.periodTypeToApiParam(periodType),
    };

    if (startDate != null) {
      params['startDate'] = StatisticsDateUtils.formatDateForApi(startDate!);
    }

    if (endDate != null) {
      params['endDate'] = StatisticsDateUtils.formatDateForApi(endDate!);
    }

    return params;
  }
}
