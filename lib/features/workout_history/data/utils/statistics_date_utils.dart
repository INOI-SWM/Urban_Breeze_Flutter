import 'package:urban_breeze/shared/utils/period_utils.dart';

import '../../domain/enums/statistic_enums.dart';

/// 통계 API를 위한 날짜 계산 유틸리티
class StatisticsDateUtils {
  /// 기간 타입과 년/월/주차 정보로부터 startDate, endDate를 계산합니다.
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

  /// 주간 날짜 범위 계산 (PeriodUtils 직접 사용)
  static DateRange _calculateWeekRange(int year, int month, int week) {
    final DateTime startOfWeek = PeriodUtils.getStartOfWeek(year, month, week);
    final DateTime endOfWeek = PeriodUtils.getEndOfWeek(year, month, week);

    // 종료일 시간을 23:59:59로 설정
    final DateTime adjustedEnd = DateTime(
      endOfWeek.year,
      endOfWeek.month,
      endOfWeek.day,
      23,
      59,
      59,
    );

    return DateRange(startDate: startOfWeek, endDate: adjustedEnd);
  }

  /// 월간 날짜 범위 계산 (PeriodUtils 직접 사용)
  static DateRange _calculateMonthRange(int year, int month) {
    final DateTime startDate = PeriodUtils.getStartOfMonth(year, month);
    final DateTime endDate = PeriodUtils.getEndOfMonth(year, month);

    return DateRange(startDate: startDate, endDate: endDate);
  }

  /// 연간 날짜 범위 계산 (PeriodUtils 직접 사용)
  static DateRange _calculateYearRange(int year) {
    final DateTime startDate = PeriodUtils.getStartOfYear(year);
    final DateTime endDate = PeriodUtils.getEndOfYear(year);

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
