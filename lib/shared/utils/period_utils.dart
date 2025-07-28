class PeriodUtils {
  static int getWeekOfMonth(DateTime date) {
    final DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday;
    final int day = date.day;
    return ((day + firstWeekday - 2) ~/ 7) + 1;
  }

  static int getWeeksInMonth(int year, int month) {
    final DateTime firstDay = DateTime(year, month, 1);
    final DateTime lastDay = DateTime(year, month + 1, 0);
    final int daysInMonth = lastDay.day;
    final int firstWeekday = firstDay.weekday;
    final int totalDays = daysInMonth + firstWeekday - 1;
    return (totalDays / 7).ceil();
  }

  static DateTime getStartOfWeek(int year, int month, int week) {
    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int firstWeekday = firstDayOfMonth.weekday;
    final int daysToAdd = (week - 1) * 7 - (firstWeekday - 1);
    return firstDayOfMonth.add(Duration(days: daysToAdd));
  }

  static DateTime getEndOfWeek(int year, int month, int week) {
    final DateTime startOfWeek = getStartOfWeek(year, month, week);
    return startOfWeek.add(const Duration(days: 6));
  }

  static String formatWeekRange(int year, int month, int week) {
    final DateTime startDate = getStartOfWeek(year, month, week);
    final DateTime endDate = getEndOfWeek(year, month, week);

    final int startMonth = startDate.month;
    final int startDay = startDate.day;
    final int endMonth = endDate.month;
    final int endDay = endDate.day;

    if (startMonth == endMonth) {
      return '($startMonth/$startDay - $endMonth/$endDay)';
    } else {
      return '($startMonth/$startDay - $endMonth/$endDay)';
    }
  }
}
