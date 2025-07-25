import 'package:flutter/cupertino.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/modal/modal_show.dart';

import '../../domain/enums/statistic_enums.dart';

class _PeriodSelectorConstants {
  static const double pickerItemExtent = 50.0;
  static const int firstMonth = 1;
  static const int lastMonth = 12;
  static const int firstWeek = 1;
}

class PeriodSelection {
  const PeriodSelection({
    required this.year,
    required this.month,
    required this.week,
  });
  final int year;
  final int month;
  final int week;

  PeriodSelection copyWith({int? year, int? month, int? week}) {
    return PeriodSelection(
      year: year ?? this.year,
      month: month ?? this.month,
      week: week ?? this.week,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PeriodSelection &&
        other.year == year &&
        other.month == month &&
        other.week == week;
  }

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ week.hashCode;
}

class PeriodSelectorDialog {
  static Future<void> show(
    BuildContext context, {
    required StatisticPeriodType periodType,
    required PeriodSelection initialSelection,
    required ValueChanged<PeriodSelection> onPeriodChanged,
    DateTime? startDate,
  }) {
    final DateTime now = DateTime.now();
    final int startYear = startDate?.year ?? now.year;
    final int endYear = now.year;

    final ValueNotifier<PeriodSelection> selectionNotifier =
        ValueNotifier<PeriodSelection>(initialSelection);

    return ModalShow.show(
      context: context,
      title: '기간 선택',
      content: _PeriodSelectorContent(
        periodType: periodType,
        initialSelection: initialSelection,
        startYear: startYear,
        endYear: endYear,
        startDate: startDate,
        onSelectionChanged:
            (PeriodSelection selection) => selectionNotifier.value = selection,
      ),
      primaryButtonText: '확인',
      secondaryButtonText: '취소',
      onPrimaryButtonPressed: () {
        onPeriodChanged(selectionNotifier.value);
      },
      onSecondaryButtonPressed: () {},
    );
  }
}

class _PeriodSelectorContent extends StatefulWidget {
  const _PeriodSelectorContent({
    required this.periodType,
    required this.initialSelection,
    required this.startYear,
    required this.endYear,
    required this.onSelectionChanged,
    this.startDate,
  });

  final StatisticPeriodType periodType;
  final PeriodSelection initialSelection;
  final int startYear;
  final int endYear;
  final DateTime? startDate;
  final ValueChanged<PeriodSelection> onSelectionChanged;

  @override
  State<_PeriodSelectorContent> createState() => _PeriodSelectorContentState();
}

class _PeriodSelectorContentState extends State<_PeriodSelectorContent> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedWeek;

  final DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialSelection.year;
    _selectedMonth = widget.initialSelection.month;
    _selectedWeek = widget.initialSelection.week;

    _adjustMonthIfNeeded();
    _adjustWeekIfNeeded();
  }

  void _notifySelection() {
    widget.onSelectionChanged(
      PeriodSelection(
        year: _selectedYear,
        month: _selectedMonth,
        week: _selectedWeek,
      ),
    );
  }

  int get _yearCount => widget.endYear - widget.startYear + 1;

  int _getYearIndexFromYear(int year) => year - widget.startYear;

  int _getYearFromIndex(int index) => widget.startYear + index;

  List<String> _generateYearItems() {
    return List<String>.generate(_yearCount, (int index) {
      final int year = _getYearFromIndex(index);
      return '$year년';
    });
  }

  List<String> _generateMonthItems() {
    final int minMonth = _DateRangeCalculator.getMinMonthForYear(
      _selectedYear,
      widget.startDate,
    );
    final int maxMonth = _DateRangeCalculator.getMaxMonthForYear(
      _selectedYear,
      _now,
    );
    return List<String>.generate(maxMonth - minMonth + 1, (int index) {
      final int month = minMonth + index;
      return '$month월';
    });
  }

  List<String> _generateWeekItems() {
    final int minWeek = _DateRangeCalculator.getMinWeekForYearMonth(
      _selectedYear,
      _selectedMonth,
      widget.startDate,
    );
    final int maxWeek = _DateRangeCalculator.getMaxWeekForYearMonth(
      _selectedYear,
      _selectedMonth,
      _now,
    );
    return List<String>.generate(maxWeek - minWeek + 1, (int index) {
      final int week = minWeek + index;
      return '$week주';
    });
  }

  void _onWeekChanged(int index) {
    setState(() {
      final int minWeek = _DateRangeCalculator.getMinWeekForYearMonth(
        _selectedYear,
        _selectedMonth,
        widget.startDate,
      );
      _selectedWeek = minWeek + index;
    });
    _notifySelection();
  }

  void _adjustMonthIfNeeded() {
    final int maxMonth = _DateRangeCalculator.getMaxMonthForYear(
      _selectedYear,
      _now,
    );
    final int minMonth = _DateRangeCalculator.getMinMonthForYear(
      _selectedYear,
      widget.startDate,
    );
    _selectedMonth = _selectedMonth.clamp(minMonth, maxMonth);
  }

  void _adjustWeekIfNeeded() {
    final int maxWeek = _DateRangeCalculator.getMaxWeekForYearMonth(
      _selectedYear,
      _selectedMonth,
      _now,
    );
    final int minWeek = _DateRangeCalculator.getMinWeekForYearMonth(
      _selectedYear,
      _selectedMonth,
      widget.startDate,
    );
    _selectedWeek = _selectedWeek.clamp(minWeek, maxWeek);
  }

  int _getSelectedMonthIndex() {
    final int minMonth = _DateRangeCalculator.getMinMonthForYear(
      _selectedYear,
      widget.startDate,
    );
    return (_selectedMonth - minMonth).clamp(
      0,
      _generateMonthItems().length - 1,
    );
  }

  int _getSelectedWeekIndex() {
    final int minWeek = _DateRangeCalculator.getMinWeekForYearMonth(
      _selectedYear,
      _selectedMonth,
      widget.startDate,
    );
    return (_selectedWeek - minWeek).clamp(0, _generateWeekItems().length - 1);
  }

  void _onYearChanged(int index) {
    setState(() {
      _selectedYear = _getYearFromIndex(index);
      _adjustMonthIfNeeded();
      _adjustWeekIfNeeded();
    });
    _notifySelection();
  }

  void _onMonthChanged(int index) {
    setState(() {
      final int minMonth = _DateRangeCalculator.getMinMonthForYear(
        _selectedYear,
        widget.startDate,
      );
      _selectedMonth = minMonth + index;
      _adjustWeekIfNeeded();
    });
    _notifySelection();
  }

  void _onYearChangedForMonth(int index) {
    setState(() {
      _selectedYear = _getYearFromIndex(index);
      _adjustMonthIfNeeded();
    });
    _notifySelection();
  }

  void _onMonthChangedForMonth(int index) {
    setState(() {
      final int minMonth = _DateRangeCalculator.getMinMonthForYear(
        _selectedYear,
        widget.startDate,
      );
      _selectedMonth = minMonth + index;
    });
    _notifySelection();
  }

  void _onYearChangedForYear(int index) {
    setState(() {
      _selectedYear = _getYearFromIndex(index);
    });
    _notifySelection();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildPeriodSelectorContent(),
    );
  }

  Widget _buildPeriodSelectorContent() {
    switch (widget.periodType) {
      case StatisticPeriodType.week:
        return _buildWeekSelector();
      case StatisticPeriodType.month:
        return _buildMonthSelector();
      case StatisticPeriodType.year:
        return _buildYearSelector();
      case StatisticPeriodType.all:
        // 전체 기간은 팝업이 뜨지 않으므로 이 코드는 실행되지 않음
        throw StateError('All period type should not show dialog');
    }
  }

  Widget _buildWeekSelector() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 200,
          child: Row(
            children: <Widget>[
              Expanded(
                child: _CustomPicker(
                  items: _generateYearItems(),
                  selectedIndex: _getYearIndexFromYear(_selectedYear),
                  onChanged: _onYearChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CustomPicker(
                  items: _generateMonthItems(),
                  selectedIndex: _getSelectedMonthIndex(),
                  onChanged: _onMonthChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CustomPicker(
                  items: _generateWeekItems(),
                  selectedIndex: _getSelectedWeekIndex(),
                  onChanged: _onWeekChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 200,
          child: Row(
            children: <Widget>[
              Expanded(
                child: _CustomPicker(
                  items: _generateYearItems(),
                  selectedIndex: _getYearIndexFromYear(_selectedYear),
                  onChanged: _onYearChangedForMonth,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _CustomPicker(
                  items: _generateMonthItems(),
                  selectedIndex: _getSelectedMonthIndex(),
                  onChanged: _onMonthChangedForMonth,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYearSelector() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 200,
          child: _CustomPicker(
            items: _generateYearItems(),
            selectedIndex: _getYearIndexFromYear(_selectedYear),
            onChanged: _onYearChangedForYear,
          ),
        ),
      ],
    );
  }
}

class _DateRangeCalculator {
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

  static int getMinMonthForYear(int year, DateTime? startDate) {
    if (startDate != null && year == startDate.year) {
      return startDate.month;
    }
    return _PeriodSelectorConstants.firstMonth;
  }

  static int getMaxMonthForYear(int year, DateTime currentDate) {
    if (year == currentDate.year) {
      return currentDate.month;
    }
    return _PeriodSelectorConstants.lastMonth;
  }

  static int getMinWeekForYearMonth(int year, int month, DateTime? startDate) {
    if (startDate != null &&
        year == startDate.year &&
        month == startDate.month) {
      return getWeekOfMonth(startDate);
    }
    return _PeriodSelectorConstants.firstWeek;
  }

  static int getMaxWeekForYearMonth(int year, int month, DateTime currentDate) {
    if (year == currentDate.year && month == currentDate.month) {
      return getWeekOfMonth(currentDate);
    }
    return getWeeksInMonth(year, month);
  }
}

class _CustomPicker extends StatelessWidget {
  const _CustomPicker({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      itemExtent: _PeriodSelectorConstants.pickerItemExtent,
      scrollController: FixedExtentScrollController(initialItem: selectedIndex),
      onSelectedItemChanged: onChanged,
      children:
          items.asMap().entries.map((MapEntry<int, String> entry) {
            return Center(
              child: Text(
                entry.value,
                style: AppTextStyles.body1.readingMedium.copyWith(
                  color: context.semanticColor.labelStrong,
                ),
              ),
            );
          }).toList(),
    );
  }
}
