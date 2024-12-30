import 'package:intl/intl.dart';
import 'package:zoroastriancalendar/database.dart';
import 'package:zoroastriancalendar/models/calendar_event.dart';
import 'package:zoroastriancalendar/models/enum_models.dart';
import 'package:zoroastriancalendar/models/month_tab_model.dart';
import 'package:zoroastriancalendar/models/month_tab_view_model.dart';
import 'package:zoroastriancalendar/models/zorastrian_date.dart';
import 'package:zoroastriancalendar/utilities.dart';

class MonthTabLogic {
  late MonthTabModel model;
  Future<List<String>> get mahCollection async =>
      await DBProvider.db.mahCollection;
  final yearCollection = [for (var i = 1900; i <= 2100; i += 1) i]; //1900-2100
  final salCollection = [for (var i = 1268; i <= 1470; i += 1) i]; //1268-1470
  void setModel(MonthTabModel model) {
    this.model = model;
  }

  Future<void> setNextMonth() async {
    final yc = (model.mode == MonthTabCalendarMode.Zoroastrian)
        ? salCollection
        : yearCollection;
    switch (model.mode) {
      case MonthTabCalendarMode.Gregorian:
        final newSelectedDate = DateTime(model.selectedDate.year,
            model.selectedDate.month + 1, model.selectedDate.day);
        if (!yc.contains(newSelectedDate.year)) {
          break;
        }
        model = model.copyWith(selectedDate: newSelectedDate);
        break;
      case MonthTabCalendarMode.Zoroastrian:
        final currentZorastrianDate =
            await DBProvider.db.getZorastrianDate(model.selectedDate);
        final rojName = "Hormazd";
        final currentMahName =
            currentZorastrianDate.getMahName(model.calendarType);
        final mc = await mahCollection;
        final newMahName = (currentMahName == "Asfandarmad")
            ? "Fravardin"
            : mc[mc.indexOf(
                    currentZorastrianDate.getMahName(model.calendarType)) +
                1];
        final year = (currentMahName == "Asfandarmad")
            ? currentZorastrianDate.getYear(model.calendarType) + 1
            : currentZorastrianDate.getYear(model.calendarType);
        final calendarType = (await DBProvider.db.calendarTypes)
            .where((x) => x.name == model.calendarType)
            .single;
        final newZorastrianDate = await DBProvider.db
            .getZorastrianDateRaw(calendarType, rojName, newMahName, year);
        final newDate = DateTime(
          newZorastrianDate.gregorianDate.year,
          newZorastrianDate.gregorianDate.month,
          newZorastrianDate.gregorianDate.day,
        );
        model = model.copyWith(selectedDate: newDate);
        break;
    }
  }

  Future<void> setPreviousMonth() async {
    final yc = (model.mode == MonthTabCalendarMode.Zoroastrian)
        ? salCollection
        : yearCollection;
    switch (model.mode) {
      case MonthTabCalendarMode.Gregorian:
        final newSelectedDate = DateTime(model.selectedDate.year,
            model.selectedDate.month - 1, model.selectedDate.day);
        if (!yc.contains(newSelectedDate.year)) {
          break;
        }
        model = model.copyWith(selectedDate: newSelectedDate);
        break;
      case MonthTabCalendarMode.Zoroastrian:
        final currentZorastrianDate =
            await DBProvider.db.getZorastrianDate(model.selectedDate);
        final rojName = "Hormazd";
        final currentMahName =
            currentZorastrianDate.getMahName(model.calendarType);
        final mc = await mahCollection;
        final newMahName = (currentMahName == "Fravardin")
            ? "Asfandarmad"
            : mc[mc.indexOf(
                    currentZorastrianDate.getMahName(model.calendarType)) -
                1];
        final year = (currentMahName == "Fravardin")
            ? currentZorastrianDate.getYear(model.calendarType) - 1
            : currentZorastrianDate.getYear(model.calendarType);
        if (!yc.contains(year)) {
          break;
        }
        final calendarType = (await DBProvider.db.calendarTypes)
            .where((x) => x.name == model.calendarType)
            .single;
        final newZorastrianDate = await DBProvider.db
            .getZorastrianDateRaw(calendarType, rojName, newMahName, year);
        final newDate = DateTime(
          newZorastrianDate.gregorianDate.year,
          newZorastrianDate.gregorianDate.month,
          newZorastrianDate.gregorianDate.day,
        );
        model = model.copyWith(selectedDate: newDate);
        break;
    }
  }

  Future<void> setMonth(String month) async {
    switch (model.mode) {
      case MonthTabCalendarMode.Gregorian:
        final newMonth = month.toMonthInt();
        final newSelectedDate =
            DateTime(model.selectedDate.year, newMonth, model.selectedDate.day);
        model = model.copyWith(selectedDate: newSelectedDate);
        break;
      case MonthTabCalendarMode.Zoroastrian:
        final currentZorastrianDate =
            await DBProvider.db.getZorastrianDate(model.selectedDate);
        final rojName = "Hormazd";
        final newMahName = month;
        final year = currentZorastrianDate.getYear(model.calendarType);
        final calendarType = (await DBProvider.db.calendarTypes)
            .where((x) => x.name == model.calendarType)
            .single;
        final newZorastrianDate = await DBProvider.db
            .getZorastrianDateRaw(calendarType, rojName, newMahName, year);
        final newDate = DateTime(
          newZorastrianDate.gregorianDate.year,
          newZorastrianDate.gregorianDate.month,
          newZorastrianDate.gregorianDate.day,
        );
        model = model.copyWith(selectedDate: newDate);
        break;
    }
  }

  Future<void> setNextYear() async {
    final yc = (model.mode == MonthTabCalendarMode.Zoroastrian)
        ? salCollection
        : yearCollection;
    switch (model.mode) {
      case MonthTabCalendarMode.Gregorian:
        if (!yc.contains(model.selectedDate.year + 1)) {
          break;
        }
        final newSelectedDate = DateTime(model.selectedDate.year + 1,
            model.selectedDate.month, model.selectedDate.day);
        model = model.copyWith(selectedDate: newSelectedDate);
        break;
      case MonthTabCalendarMode.Zoroastrian:
        final currentZorastrianDate =
            await DBProvider.db.getZorastrianDate(model.selectedDate);
        var rojName = currentZorastrianDate.getRojName(model.calendarType);
        final mahName = currentZorastrianDate.getMahName(model.calendarType);
        final year = currentZorastrianDate.getYear(model.calendarType) + 1;
        if (!yc.contains(year)) {
          break;
        }
        final calendarType = (await DBProvider.db.calendarTypes)
            .where((x) => x.name == model.calendarType)
            .single;
        final newZorastrianDate = await DBProvider.db
            .getZorastrianDateRaw(calendarType, rojName, mahName, year);
        final newDate = DateTime(
          newZorastrianDate.gregorianDate.year,
          newZorastrianDate.gregorianDate.month,
          newZorastrianDate.gregorianDate.day,
        );
        model = model.copyWith(selectedDate: newDate);
        break;
    }
  }

  Future<void> setPreviousYear() async {
    final yc = (model.mode == MonthTabCalendarMode.Zoroastrian)
        ? salCollection
        : yearCollection;
    switch (model.mode) {
      case MonthTabCalendarMode.Gregorian:
        if (!yc.contains(model.selectedDate.year - 1)) {
          break;
        }
        final newSelectedDate = DateTime(model.selectedDate.year - 1,
            model.selectedDate.month, model.selectedDate.day);
        model = model.copyWith(selectedDate: newSelectedDate);
        break;
      case MonthTabCalendarMode.Zoroastrian:
        final currentZorastrianDate =
            await DBProvider.db.getZorastrianDate(model.selectedDate);
        var rojName = currentZorastrianDate.getRojName(model.calendarType);
        final mahName = currentZorastrianDate.getMahName(model.calendarType);
        final year = currentZorastrianDate.getYear(model.calendarType) - 1;

        if (!yc.contains(year)) {
          break;
        }
        final calendarType = (await DBProvider.db.calendarTypes)
            .where((x) => x.name == model.calendarType)
            .single;
        final newZorastrianDate = await DBProvider.db
            .getZorastrianDateRaw(calendarType, rojName, mahName, year);
        final newDate = DateTime(
          newZorastrianDate.gregorianDate.year,
          newZorastrianDate.gregorianDate.month,
          newZorastrianDate.gregorianDate.day,
        );
        model = model.copyWith(selectedDate: newDate);
        break;
    }
  }

  Future<void> setYear(int year) async {
    final yc = (model.mode == MonthTabCalendarMode.Zoroastrian)
        ? salCollection
        : yearCollection;
    switch (model.mode) {
      case MonthTabCalendarMode.Gregorian:
        if (!yc.contains(year)) {
          break;
        }
        final newSelectedDate =
            DateTime(year, model.selectedDate.month, model.selectedDate.day);
        model = model.copyWith(selectedDate: newSelectedDate);
        break;
      case MonthTabCalendarMode.Zoroastrian:
        final currentZorastrianDate =
            await DBProvider.db.getZorastrianDate(model.selectedDate);
        var rojName = currentZorastrianDate.getRojName(model.calendarType);
        final mahName = currentZorastrianDate.getMahName(model.calendarType);
        if (!yc.contains(year)) {
          break;
        }
        final calendarType = (await DBProvider.db.calendarTypes)
            .where((x) => x.name == model.calendarType)
            .single;
        final newZorastrianDate = await DBProvider.db
            .getZorastrianDateRaw(calendarType, rojName, mahName, year);
        final newDate = DateTime(
          newZorastrianDate.gregorianDate.year,
          newZorastrianDate.gregorianDate.month,
          newZorastrianDate.gregorianDate.day,
        );
        model = model.copyWith(selectedDate: newDate);
        break;
    }
  }

  Future<MonthTabViewModel> getMonthTabData() async {
    final rawList = await DBProvider.db
        .getMonthTabData(model.selectedDate, model.calendarType, model.mode);
    final tableData = List<List<DayInMonthTabViewModel>>.empty(growable: true);
    tableData.add(_getTableHeader());
    tableData.addAll(_getTableBody(rawList));
    final mc = (model.mode == MonthTabCalendarMode.Zoroastrian)
        ? await DBProvider.db.mahCollection
        : Month.values.map((e) => e.name).toList();
    final yc = (model.mode == MonthTabCalendarMode.Zoroastrian)
        ? salCollection
        : yearCollection;
    final pcm = (model.mode == MonthTabCalendarMode.Zoroastrian)
        ? calendarPicker(
            model.calendarType,
            rawList.first.key.shahanshahiMahName,
            rawList.first.key.kadmiMahName,
            rawList.first.key.fasliMahName)
        : DateFormat(DateFormat.MONTH).format(rawList.first.key.gregorianDate);
    final pcy = (model.mode == MonthTabCalendarMode.Zoroastrian)
        ? calendarPicker(model.calendarType, rawList.first.key.shahanshahiYear,
            rawList.first.key.kadmiYear, rawList.first.key.fasliYear)
        : rawList.first.key.gregorianDate.year;
    final scfm = (model.mode == MonthTabCalendarMode.Zoroastrian)
        ? DateFormat(DateFormat.ABBR_MONTH)
            .format(rawList.first.key.gregorianDate)
        : calendarPicker(
            model.calendarType,
            rawList.first.key.shahanshahiMahName,
            rawList.first.key.kadmiMahName,
            rawList.first.key.fasliMahName);
    final scfy = (model.mode == MonthTabCalendarMode.Zoroastrian)
        ? rawList.first.key.gregorianDate.year
        : calendarPicker(model.calendarType, rawList.first.key.shahanshahiYear,
            rawList.first.key.kadmiYear, rawList.first.key.fasliYear);
    final sctm = (model.mode == MonthTabCalendarMode.Zoroastrian)
        ? DateFormat(DateFormat.ABBR_MONTH)
            .format(rawList.last.key.gregorianDate)
        : calendarPicker(
            model.calendarType,
            rawList.last.key.shahanshahiMahName,
            rawList.last.key.kadmiMahName,
            rawList.last.key.fasliMahName);
    final scty = (model.mode == MonthTabCalendarMode.Zoroastrian)
        ? rawList.last.key.gregorianDate.year
        : calendarPicker(model.calendarType, rawList.last.key.shahanshahiYear,
            rawList.last.key.kadmiYear, rawList.last.key.fasliYear);

    return MonthTabViewModel(
        tableData: tableData,
        monthCollection: mc,
        yearCollection: yc,
        primaryCalendarMonth: pcm,
        primaryCalendarYear: pcy,
        secondaryCalendarFromMonth: scfm,
        secondaryCalendarFromYear: scfy,
        secondaryCalendarToMonth: sctm,
        secondaryCalendarToYear: scty);
  }

  List<DayInMonthTabViewModel> _getTableHeader() {
    return <DayInMonthTabViewModel>[
      HeaderCellInDayInMonthTabViewModel(
          nameOfDay: "Sunday", nameOfDayShort: "Sun"),
      HeaderCellInDayInMonthTabViewModel(
          nameOfDay: "Monday", nameOfDayShort: "Mon"),
      HeaderCellInDayInMonthTabViewModel(
          nameOfDay: "Tuesday", nameOfDayShort: "Tue"),
      HeaderCellInDayInMonthTabViewModel(
          nameOfDay: "Wednesday", nameOfDayShort: "Wed"),
      HeaderCellInDayInMonthTabViewModel(
          nameOfDay: "Thursday", nameOfDayShort: "Thurs"),
      HeaderCellInDayInMonthTabViewModel(
          nameOfDay: "Friday", nameOfDayShort: "Fri"),
      HeaderCellInDayInMonthTabViewModel(
          nameOfDay: "Saturday", nameOfDayShort: "Sat")
    ];
  }

  List<List<DayInMonthTabViewModel>> _getTableBody(
      List<MapEntry<ZorastrianDate, List<CalendarEvent>>> rawList) {
    final dateTime = DateTime.now();
    final calendarName = DBProvider.calendar_key_shahenshai;
    final todaysDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final paddedRaw = List<DayInMonthTabViewModel>.empty(growable: true);
    paddedRaw.addAll(_getPrefixedEmptyCells(rawList.first.key.gregorianDate));
    paddedRaw.addAll(rawList
        .map((e) =>
            PopulatedBodyCellInDayInMonthTabViewModel.fromZorastrianDate(
                e.key, calendarName, todaysDate, e.value))
        .toList());
    paddedRaw.addAll(_getPostfixedEmptyCells(rawList.last.key.gregorianDate));
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
    late int count;
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
