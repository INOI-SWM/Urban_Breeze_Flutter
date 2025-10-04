import 'package:flutter/cupertino.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/modal/modal_show.dart';
import 'package:urban_breeze/shared/utils/period_utils.dart';

import '../../domain/entities/period_selection.dart';
import '../../domain/enums/statistic_enums.dart';

class _PeriodSelectorConstants {
  static const double pickerItemExtent = 50.0;
  static const double pickerHeight = 200.0;
  static const double pickerSpacing = 4.0;
  static const double pickerSpacingLarge = 12.0;
  static const double contentPadding = 16.0;
  static const int firstMonth = 1;
  static const int lastMonth = 12;
  static const int firstWeek = 1;
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
    _selectedMonth = widget.initialSelection.month ?? 1;
    _selectedWeek = widget.initialSelection.week ?? 1;

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

  int _getYearIndexFromYear(int year) => year - widget.startYear;

  int _getYearFromIndex(int index) => widget.startYear + index;

  int _calculateSelectedIndex(int selectedValue, int minValue, int maxValue) {
    // minValue가 maxValue보다 큰 경우를 처리
    if (minValue > maxValue) {
      return 0;
    }
    return (selectedValue - minValue).clamp(0, maxValue - minValue);
  }

  List<String> _generateItems(
    int minValue,
    int maxValue,
    String Function(int) formatter,
  ) {
    // minValue가 maxValue보다 큰 경우를 처리
    if (minValue > maxValue) {
      return <String>[formatter(maxValue)];
    }
    return List<String>.generate(maxValue - minValue + 1, (int index) {
      return formatter(minValue + index);
    });
  }

  List<String> _generateYearItems() {
    return _generateItems(
      widget.startYear,
      widget.endYear,
      _PeriodTextFormatter.formatYear,
    );
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
    return _generateItems(minMonth, maxMonth, _PeriodTextFormatter.formatMonth);
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
    return _generateItems(minWeek, maxWeek, _PeriodTextFormatter.formatWeek);
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
    final int minMonth = _DateRangeCalculator.getMinMonthForYear(
      _selectedYear,
      widget.startDate,
    );
    final int maxMonth = _DateRangeCalculator.getMaxMonthForYear(
      _selectedYear,
      _now,
    );

    // minMonth가 maxMonth보다 큰 경우를 처리
    if (minMonth > maxMonth) {
      _selectedMonth = maxMonth;
    } else {
      _selectedMonth = _selectedMonth.clamp(minMonth, maxMonth);
    }
  }

  void _adjustWeekIfNeeded() {
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

    // minWeek가 maxWeek보다 큰 경우를 처리
    if (minWeek > maxWeek) {
      _selectedWeek = maxWeek;
    } else {
      _selectedWeek = _selectedWeek.clamp(minWeek, maxWeek);
    }
  }

  int _getSelectedMonthIndex() {
    final int minMonth = _DateRangeCalculator.getMinMonthForYear(
      _selectedYear,
      widget.startDate,
    );
    final int maxMonth = _DateRangeCalculator.getMaxMonthForYear(
      _selectedYear,
      _now,
    );
    return _calculateSelectedIndex(_selectedMonth, minMonth, maxMonth);
  }

  int _getSelectedWeekIndex() {
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
    return _calculateSelectedIndex(_selectedWeek, minWeek, maxWeek);
  }

  void _onYearChanged(
    int index, {
    bool adjustMonth = true,
    bool adjustWeek = true,
  }) {
    setState(() {
      _selectedYear = _getYearFromIndex(index);
      if (adjustMonth) _adjustMonthIfNeeded();
      if (adjustWeek) _adjustWeekIfNeeded();
    });
    _notifySelection();
  }

  void _onMonthChanged(int index, {bool adjustWeek = true}) {
    setState(() {
      final int minMonth = _DateRangeCalculator.getMinMonthForYear(
        _selectedYear,
        widget.startDate,
      );
      _selectedMonth = minMonth + index;
      if (adjustWeek) _adjustWeekIfNeeded();
    });
    _notifySelection();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_PeriodSelectorConstants.contentPadding),
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

  Widget _buildPickerContainer(Widget child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: _PeriodSelectorConstants.pickerHeight, child: child),
      ],
    );
  }

  Widget _buildPickerRow(
    List<Widget> pickers, {
    double spacing = _PeriodSelectorConstants.pickerSpacing,
  }) {
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < pickers.length; i++) {
      children.add(Expanded(child: pickers[i]));
      if (i < pickers.length - 1) {
        children.add(SizedBox(width: spacing));
      }
    }
    return Row(children: children);
  }

  Widget _buildWeekSelector() {
    return _buildPickerContainer(
      _buildPickerRow(<Widget>[
        _CustomPicker(
          items: _generateYearItems(),
          selectedIndex: _getYearIndexFromYear(_selectedYear),
          onChanged: _onYearChanged,
        ),
        _CustomPicker(
          items: _generateMonthItems(),
          selectedIndex: _getSelectedMonthIndex(),
          onChanged: _onMonthChanged,
        ),
        _CustomPicker(
          items: _generateWeekItems(),
          selectedIndex: _getSelectedWeekIndex(),
          onChanged: _onWeekChanged,
        ),
      ]),
    );
  }

  Widget _buildMonthSelector() {
    return _buildPickerContainer(
      _buildPickerRow(<Widget>[
        _CustomPicker(
          items: _generateYearItems(),
          selectedIndex: _getYearIndexFromYear(_selectedYear),
          onChanged: (int index) => _onYearChanged(index, adjustWeek: false),
        ),
        _CustomPicker(
          items: _generateMonthItems(),
          selectedIndex: _getSelectedMonthIndex(),
          onChanged: (int index) => _onMonthChanged(index, adjustWeek: false),
        ),
      ], spacing: _PeriodSelectorConstants.pickerSpacingLarge),
    );
  }

  Widget _buildYearSelector() {
    return _buildPickerContainer(
      _CustomPicker(
        items: _generateYearItems(),
        selectedIndex: _getYearIndexFromYear(_selectedYear),
        onChanged:
            (int index) =>
                _onYearChanged(index, adjustMonth: false, adjustWeek: false),
      ),
    );
  }
}

class _DateRangeCalculator {
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
      return PeriodUtils.getWeekOfMonth(startDate);
    }
    return _PeriodSelectorConstants.firstWeek;
  }

  static int getMaxWeekForYearMonth(int year, int month, DateTime currentDate) {
    if (year == currentDate.year && month == currentDate.month) {
      return PeriodUtils.getWeekOfMonth(currentDate);
    }
    return PeriodUtils.getWeeksInMonth(year, month);
  }
}

class _PeriodTextFormatter {
  static String formatYear(int year) => '$year년';
  static String formatMonth(int month) => '$month월';
  static String formatWeek(int week) => '$week주';
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
