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
  }) {
    final ValueNotifier<PeriodSelection> selectionNotifier =
        ValueNotifier<PeriodSelection>(initialSelection);

    return ModalShow.show(
      context: context,
      title: '기간 선택',
      content: _PeriodSelectorContent(
        periodType: periodType,
        initialSelection: initialSelection,
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
    required this.onSelectionChanged,
  });

  final StatisticPeriodType periodType;
  final PeriodSelection initialSelection;
  final ValueChanged<PeriodSelection> onSelectionChanged;

  @override
  State<_PeriodSelectorContent> createState() => _PeriodSelectorContentState();
}

class _PeriodSelectorContentState extends State<_PeriodSelectorContent> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedWeek;

  // ScrollController를 멤버 변수로 선언
  late FixedExtentScrollController _weekScrollController;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialSelection.year;
    _selectedMonth = widget.initialSelection.month;
    _selectedWeek = widget.initialSelection.week;

    // 주차 ScrollController 초기화
    _weekScrollController = FixedExtentScrollController(
      initialItem: _selectedWeek - 1,
    );
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
    _selectedWeek = 1;
    if (_weekScrollController.hasClients) {
      _weekScrollController.animateTo(
        0, // 1주차 = index 0
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
                    initialItem: _selectedYear - 2020,
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedYear = 2020 + index;
                      _updateWeekToFirst();
                    });
                    _notifySelection();
                  },
                  children: List<Widget>.generate(10, (int index) {
                    final int year = 2020 + index;
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
              // 월 선택
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 50,
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedMonth - 1,
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedMonth = index + 1;
                      _updateWeekToFirst(); // 월 변경 시 주차 초기화 및 스크롤
                    });
                    _notifySelection();
                  },
                  children: List<Widget>.generate(12, (int index) {
                    final int month = index + 1;
                    return Center(
                      child: Text(
                        '$month월',
                        style: AppTextStyles.body1.readingMedium.copyWith(
                          color: context.semanticColor.labelStrong,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 12),
              // 주차 선택
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 50,
                  scrollController: _weekScrollController,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedWeek = index + 1;
                    });
                    _notifySelection();
                  },
                  children: List<Widget>.generate(
                    _getWeeksInMonth(_selectedYear, _selectedMonth),
                    (int index) {
                      final int week = index + 1;
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
              // 년도 선택
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 50,
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedYear - 2020,
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedYear = 2020 + index;
                    });
                    _notifySelection();
                  },
                  children: List<Widget>.generate(10, (int index) {
                    final int year = 2020 + index;
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
              // 월 선택
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 50,
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedMonth - 1,
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedMonth = index + 1;
                    });
                    _notifySelection();
                  },
                  children: List<Widget>.generate(12, (int index) {
                    final int month = index + 1;
                    return Center(
                      child: Text(
                        '$month월',
                        style: AppTextStyles.body1.readingMedium.copyWith(
                          color: context.semanticColor.labelStrong,
                        ),
                      ),
                    );
                  }),
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
              initialItem: _selectedYear - 2020, // 2020년부터 시작
            ),
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedYear = 2020 + index;
              });
              _notifySelection();
            },
            children: List<Widget>.generate(
              10, // 2020년부터 2029년까지
              (int index) {
                final int year = 2020 + index;
                return Center(
                  child: Text(
                    '$year년',
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
