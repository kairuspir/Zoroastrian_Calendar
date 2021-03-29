import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'zorastrian_date.dart';
import '../utilities.dart';

class MonthTabViewModel {
  final List<List<DayInMonthTabViewModel>> tableData;

  const MonthTabViewModel({@required this.tableData});
}

class DayInMonthTabViewModel {
  const DayInMonthTabViewModel();
}

class HeaderCellInDayInMonthTabViewModel extends DayInMonthTabViewModel {
  final String nameOfDay;
  const HeaderCellInDayInMonthTabViewModel({@required this.nameOfDay});
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

  const PopulatedBodyCellInDayInMonthTabViewModel(
      {@required this.isToday,
      @required this.dayOfMonth,
      @required this.gregorianMonthName,
      @required this.rojName,
      @required this.mahName});

  factory PopulatedBodyCellInDayInMonthTabViewModel.fromZoraztrianDate(
          ZorastrianDate date, String calendarName, DateTime todaysDate) =>
      PopulatedBodyCellInDayInMonthTabViewModel(
          isToday: date.gregorianDate.isSameDate(todaysDate),
          dayOfMonth: date.gregorianDate.day,
          gregorianMonthName:
              DateFormat(DateFormat.ABBR_MONTH).format(date.gregorianDate),
          rojName: date.getRojName(calendarName),
          mahName: date.getMahName(calendarName));
}
