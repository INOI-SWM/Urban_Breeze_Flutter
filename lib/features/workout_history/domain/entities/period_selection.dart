/// 기간 선택을 나타내는 도메인 엔티티
class PeriodSelection {
  const PeriodSelection({required this.year, this.month, this.week});

  final int year;
  final int? month;
  final int? week;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PeriodSelection &&
        other.year == year &&
        other.month == month &&
        other.week == week;
  }

  @override
  int get hashCode => Object.hash(year, month, week);

  @override
  String toString() {
    return 'PeriodSelection(year: $year, month: $month, week: $week)';
  }

  PeriodSelection copyWith({int? year, int? month, int? week}) {
    return PeriodSelection(
      year: year ?? this.year,
      month: month ?? this.month,
      week: week ?? this.week,
    );
  }
}
