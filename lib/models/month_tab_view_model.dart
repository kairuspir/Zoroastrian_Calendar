import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:zoroastriancalendar/models/calendar_event.dart';

import 'zorastrian_date.dart';
import '../utilities.dart';

class MonthTabViewModel {
  final List<List<DayInMonthTabViewModel>> tableData;
  final List<String> monthCollection;
  final List<int> yearCollection;
  final String primaryCalendarMonth;
  final int primaryCalendarYear;
  final String secondaryCalendarFromMonth;
  final String secondaryCalendarToMonth;
  final int secondaryCalendarFromYear;
  final int secondaryCalendarToYear;

  const MonthTabViewModel(
      {@required this.tableData,
      @required this.monthCollection,
      @required this.yearCollection,
      @required this.primaryCalendarMonth,
      @required this.primaryCalendarYear,
      @required this.secondaryCalendarFromMonth,
      @required this.secondaryCalendarToMonth,
      @required this.secondaryCalendarFromYear,
      @required this.secondaryCalendarToYear});
}

class DayInMonthTabViewModel {
  const DayInMonthTabViewModel();
}

class HeaderCellInDayInMonthTabViewModel extends DayInMonthTabViewModel {
  final String nameOfDay;
  final String nameOfDayShort;
  const HeaderCellInDayInMonthTabViewModel(
      {@required this.nameOfDay, @required this.nameOfDayShort});
}

class BodyCellInDayInMonthTabViewModel extends DayInMonthTabViewModel {
  const BodyCellInDayInMonthTabViewModel();
}

class EmptyBodyCellInDayInMonthTabViewModel
    extends BodyCellInDayInMonthTabViewModel {
  const EmptyBodyCellInDayInMonthTabViewModel();
}

class PopulatedBodyCellInDayInMonthTabViewModel
    extends BodyCellInDayInMonthTabViewModel {
  final bool isToday;
  final int dayOfMonth;
  final String gregorianMonthName;
  final String rojName;
  final String mahName;
  final DateTime gregorianDate;
  final List<CalendarEvent> events;

  const PopulatedBodyCellInDayInMonthTabViewModel(
      {@required this.isToday,
      @required this.dayOfMonth,
      @required this.gregorianMonthName,
      @required this.rojName,
      @required this.mahName,
      @required this.gregorianDate,
      @required this.events});

  factory PopulatedBodyCellInDayInMonthTabViewModel.fromZorastrianDate(
          ZorastrianDate date,
          String calendarName,
          DateTime todaysDate,
          List<CalendarEvent> events) =>
      PopulatedBodyCellInDayInMonthTabViewModel(
          isToday: date.gregorianDate.isSameDate(todaysDate),
          dayOfMonth: date.gregorianDate.day,
          gregorianMonthName:
              DateFormat(DateFormat.ABBR_MONTH).format(date.gregorianDate),
          rojName: date.getRojName(calendarName),
          mahName: date.getMahName(calendarName),
          gregorianDate: date.gregorianDate,
          events: events);
}
