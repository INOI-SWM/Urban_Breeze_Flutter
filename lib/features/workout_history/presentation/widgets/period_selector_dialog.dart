import 'package:flutter/cupertino.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/modal/modal_show.dart';

import '../../domain/enums/statistic_enums.dart';

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
    int? startYear, // 시작 년도 (기본값: null이면 현재 년도)
    DateTime? startDate, // 시작 날짜 (기본값: null이면 제한 없음)
  }) {
    final int effectiveStartYear = startYear ?? DateTime.now().year;
    final int endYear = DateTime.now().year;

    final ValueNotifier<PeriodSelection> selectionNotifier =
        ValueNotifier<PeriodSelection>(initialSelection);

    return ModalShow.show(
      context: context,
      title: '기간 선택',
      content: _PeriodSelectorContent(
        periodType: periodType,
        initialSelection: initialSelection,
        startYear: effectiveStartYear,
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

  late FixedExtentScrollController _weekScrollController;

  final DateTime _now = DateTime.now();
  late int _currentYear;
  late int _currentMonth;
  late int _currentWeek;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialSelection.year;
    _selectedMonth = widget.initialSelection.month;
    _selectedWeek = widget.initialSelection.week;

    _currentYear = _now.year;
    _currentMonth = _now.month;
    _currentWeek = _getCurrentWeekOfMonth();

    // 초기값 조정
    _adjustMonthIfNeeded();
    _adjustWeekIfNeeded();

    // 조정된 값으로 ScrollController 초기화
    final int minWeek = _getMinWeekForYearMonth(_selectedYear, _selectedMonth);
    final int maxWeek = _getMaxWeekForYearMonth(_selectedYear, _selectedMonth);
    final int weekIndex = (_selectedWeek - minWeek).clamp(0, maxWeek - minWeek);

    _weekScrollController = FixedExtentScrollController(initialItem: weekIndex);
  }

  // 현재 날짜의 주차 계산
  int _getCurrentWeekOfMonth() {
    final DateTime firstDayOfMonth = DateTime(_now.year, _now.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday;
    final int currentDay = _now.day;

    return ((currentDay + firstWeekday - 2) ~/ 7) + 1;
  }

  // 선택된 년월에 따른 최대 주차 계산
  int _getMaxWeekForYearMonth(int year, int month) {
    if (year == _currentYear && month == _currentMonth) {
      return _currentWeek; // 현재 년월이면 현재 주차까지만
    } else {
      return _getWeeksInMonth(year, month); // 과거 년월이면 해당 월의 모든 주차
    }
  }

  @override
  void dispose() {
    _weekScrollController.dispose();
    super.dispose();
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

  void _updateWeekToFirst() {
    final int minWeek = _getMinWeekForYearMonth(_selectedYear, _selectedMonth);
    _selectedWeek = minWeek; // 첫 번째 가능한 주차로 설정
    if (_weekScrollController.hasClients) {
      _weekScrollController.animateTo(
        0, // 첫 번째 항목으로 스크롤
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 주차 picker에서 사용할 실제 onSelectedItemChanged
  void _onWeekChanged(int index) {
    setState(() {
      final int minWeek = _getMinWeekForYearMonth(
        _selectedYear,
        _selectedMonth,
      );
      _selectedWeek = minWeek + index;
    });
    _notifySelection();
  }

  int get _yearCount => widget.endYear - widget.startYear + 1;

  int _getYearIndexFromYear(int year) => year - widget.startYear;

  int _getYearFromIndex(int index) => widget.startYear + index;

  int _getMaxMonthForYear(int year) {
    if (year == _currentYear) {
      return _currentMonth;
    } else {
      return 12;
    }
  }

  // 선택된 년도에 따른 최소 월 계산
  int _getMinMonthForYear(int year) {
    if (widget.startDate != null && year == widget.startDate!.year) {
      return widget.startDate!.month; // 시작 날짜의 월부터
    } else {
      return 1; // 일반적으로는 1월부터
    }
  }

  // 선택된 년월에 따른 최소 주차 계산
  int _getMinWeekForYearMonth(int year, int month) {
    if (widget.startDate != null &&
        year == widget.startDate!.year &&
        month == widget.startDate!.month) {
      // 시작 날짜가 포함된 주차 계산
      final DateTime firstDayOfMonth = DateTime(year, month, 1);
      final int firstWeekday = firstDayOfMonth.weekday;
      final int startDay = widget.startDate!.day;

      // 해당 날짜가 몇 번째 주인지 계산
      final int weekOfMonth = ((startDay + firstWeekday - 2) ~/ 7) + 1;
      return weekOfMonth;
    } else {
      return 1; // 일반적으로는 1주차부터
    }
  }

  void _adjustMonthIfNeeded() {
    final int maxMonth = _getMaxMonthForYear(_selectedYear);
    final int minMonth = _getMinMonthForYear(_selectedYear);
    _selectedMonth = _selectedMonth.clamp(minMonth, maxMonth);
  }

  void _adjustWeekIfNeeded() {
    final int maxWeek = _getMaxWeekForYearMonth(_selectedYear, _selectedMonth);
    final int minWeek = _getMinWeekForYearMonth(_selectedYear, _selectedMonth);
    _selectedWeek = _selectedWeek.clamp(minWeek, maxWeek);
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
                child: CupertinoPicker(
                  itemExtent: 50,
                  scrollController: FixedExtentScrollController(
                    initialItem: _getYearIndexFromYear(_selectedYear),
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedYear = _getYearFromIndex(index);
                      _adjustMonthIfNeeded();
                      _adjustWeekIfNeeded(); // 주차도 조정
                      _updateWeekToFirst();
                    });
                    _notifySelection();
                  },
                  children: List<Widget>.generate(_yearCount, (int index) {
                    final int year = _getYearFromIndex(index);
                    return Center(
                      child: Text(
                        '$year년',
                        style: AppTextStyles.body1.readingMedium.copyWith(
                          color: context.semanticColor.labelStrong,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 50,
                  scrollController: FixedExtentScrollController(
                    initialItem: (_selectedMonth -
                            _getMinMonthForYear(_selectedYear))
                        .clamp(
                          0,
                          _getMaxMonthForYear(_selectedYear) -
                              _getMinMonthForYear(_selectedYear),
                        ),
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      final int minMonth = _getMinMonthForYear(_selectedYear);
                      _selectedMonth = minMonth + index;
                      _adjustWeekIfNeeded(); // 월 변경 시 주차 조정
                      _updateWeekToFirst();
                    });
                    _notifySelection();
                  },
                  children: List<Widget>.generate(
                    _getMaxMonthForYear(_selectedYear) -
                        _getMinMonthForYear(_selectedYear) +
                        1,
                    (int index) {
                      final int month =
                          _getMinMonthForYear(_selectedYear) + index;
                      return Center(
                        child: Text(
                          '$month월',
                          style: AppTextStyles.body1.readingMedium.copyWith(
                            color: context.semanticColor.labelStrong,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 50,
                  scrollController: _weekScrollController,
                  onSelectedItemChanged: _onWeekChanged,
                  children: List<Widget>.generate(
                    _getMaxWeekForYearMonth(_selectedYear, _selectedMonth) -
                        _getMinWeekForYearMonth(_selectedYear, _selectedMonth) +
                        1,
                    (int index) {
                      final int week =
                          _getMinWeekForYearMonth(
                            _selectedYear,
                            _selectedMonth,
                          ) +
                          index;
                      return Center(
                        child: Text(
                          '$week주',
                          style: AppTextStyles.body1.readingMedium.copyWith(
                            color: context.semanticColor.labelStrong,
                          ),
                        ),
                      );
                    },
                  ),
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
                child: CupertinoPicker(
                  itemExtent: 50,
                  scrollController: FixedExtentScrollController(
                    initialItem: _getYearIndexFromYear(_selectedYear),
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedYear = _getYearFromIndex(index);
                      _adjustMonthIfNeeded();
                    });
                    _notifySelection();
                  },
                  children: List<Widget>.generate(_yearCount, (int index) {
                    final int year = _getYearFromIndex(index);
                    return Center(
                      child: Text(
                        '$year년',
                        style: AppTextStyles.body1.readingMedium.copyWith(
                          color: context.semanticColor.labelStrong,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 50,
                  scrollController: FixedExtentScrollController(
                    initialItem: (_selectedMonth -
                            _getMinMonthForYear(_selectedYear))
                        .clamp(
                          0,
                          _getMaxMonthForYear(_selectedYear) -
                              _getMinMonthForYear(_selectedYear),
                        ),
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      final int minMonth = _getMinMonthForYear(_selectedYear);
                      _selectedMonth = minMonth + index;
                    });
                    _notifySelection();
                  },
                  children: List<Widget>.generate(
                    _getMaxMonthForYear(_selectedYear) -
                        _getMinMonthForYear(_selectedYear) +
                        1,
                    (int index) {
                      final int month =
                          _getMinMonthForYear(_selectedYear) + index;
                      return Center(
                        child: Text(
                          '$month월',
                          style: AppTextStyles.body1.readingMedium.copyWith(
                            color: context.semanticColor.labelStrong,
                          ),
                        ),
                      );
                    },
                  ),
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
          child: CupertinoPicker(
            itemExtent: 50,
            scrollController: FixedExtentScrollController(
              initialItem: _getYearIndexFromYear(_selectedYear),
            ),
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedYear = _getYearFromIndex(index);
              });
              _notifySelection();
            },
            children: List<Widget>.generate(_yearCount, (int index) {
              final int year = _getYearFromIndex(index);
              return Center(
                child: Text(
                  '$year년',
                  style: AppTextStyles.body1.readingMedium.copyWith(
                    color: context.semanticColor.labelStrong,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  int _getWeeksInMonth(int year, int month) {
    final DateTime firstDay = DateTime(year, month, 1);
    final DateTime lastDay = DateTime(year, month + 1, 0);
    final int daysInMonth = lastDay.day;

    final int firstWeekday = firstDay.weekday;

    final int totalDays = daysInMonth + firstWeekday - 1;
    return (totalDays / 7).ceil();
  }
}
