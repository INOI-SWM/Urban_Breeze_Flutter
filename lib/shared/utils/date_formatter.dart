class DateFormatter {
  DateFormatter._();

  static String formatKorean(DateTime dateTime) {
    final String year = '${dateTime.year}'.substring(2);

    final String month = '${dateTime.month}월';

    final String day = '${dateTime.day}일';

    final int hour24 = dateTime.hour;
    final String period = hour24 < 12 ? '오전' : '오후';
    final int hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);

    final String minute = dateTime.minute.toString().padLeft(2, '0');

    return '$year년 $month $day $period $hour12:$minute';
  }
}
