import 'package:zoroastriancalendar/database.dart';
import 'package:zoroastriancalendar/models/enum_models.dart';
import 'package:zoroastriancalendar/models/zorastrian_date.dart';

import 'models/month_tab_view_model.dart';
import 'utilities.dart';

class MonthTabLogic {
  DateTime selectedDate;
  String calendarType;
  MonthTabCalendarMode mode;

  void initState(
      {MonthTabCalendarMode mode, DateTime selectedDate, String calendarType}) {
    this.mode = mode;
    this.selectedDate = selectedDate;
    this.calendarType = calendarType;
  }

  Future<MonthTabViewModel> getMonthTabData() async {
    final rawList =
        await DBProvider.db.getMonthTabData(selectedDate, calendarType, mode);
    final tableData = List<List<DayInMonthTabViewModel>>();
    tableData.add(_getTableHeader());
    tableData.addAll(_getTableBody(rawList));
    return MonthTabViewModel(tableData: tableData);
  }

  List<DayInMonthTabViewModel> _getTableHeader() {
    return <DayInMonthTabViewModel>[
      HeaderCellInDayInMonthTabViewModel(nameOfDay: "Sunday"),
      HeaderCellInDayInMonthTabViewModel(nameOfDay: "Monday"),
      HeaderCellInDayInMonthTabViewModel(nameOfDay: "Tuesday"),
      HeaderCellInDayInMonthTabViewModel(nameOfDay: "Wednesday"),
      HeaderCellInDayInMonthTabViewModel(nameOfDay: "Thursday"),
      HeaderCellInDayInMonthTabViewModel(nameOfDay: "Friday"),
      HeaderCellInDayInMonthTabViewModel(nameOfDay: "Saturday")
    ];
  }

  List<List<DayInMonthTabViewModel>> _getTableBody(
      List<ZorastrianDate> rawList) {
    final dateTime = DateTime.now();
    final calendarName = "";
    final todaysDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final paddedRaw = List<DayInMonthTabViewModel>();
    paddedRaw.addAll(_getPrefixedEmptyCells(rawList.first.gregorianDate));
    paddedRaw.addAll(rawList
        .map((date) =>
            PopulatedBodyCellInDayInMonthTabViewModel.fromZoraztrianDate(
                date, calendarName, todaysDate))
        .toList());
    paddedRaw.addAll(_getPostfixedEmptyCells(rawList.last.gregorianDate));
    final result = paddedRaw.chunk(7);
    return result;
  }

  List<DayInMonthTabViewModel> _getPrefixedEmptyCells(DateTime firstDate) {
    if (firstDate.weekday == DateTime.sunday) {
      return <DayInMonthTabViewModel>[];
    } else {
      return List<DayInMonthTabViewModel>.generate(firstDate.weekday,
          (index) => EmptyBodyCellInDayInMonthTabViewModel());
    }
  }

  List<DayInMonthTabViewModel> _getPostfixedEmptyCells(DateTime lastDate) {
    int count;
    switch (lastDate.weekday) {
      case DateTime.sunday:
        count = 6;
        break;
      case DateTime.monday:
        count = 5;
        break;
      case DateTime.tuesday:
        count = 4;
        break;
      case DateTime.wednesday:
        count = 3;
        break;
      case DateTime.thursday:
        count = 2;
        break;
      case DateTime.friday:
        count = 1;
        break;
      case DateTime.saturday:
        count = 0;
        break;
    }
    return List<DayInMonthTabViewModel>.generate(
        count, (index) => EmptyBodyCellInDayInMonthTabViewModel());
  }
}
