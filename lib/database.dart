import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'models/calendar_event.dart';
import 'models/calendar_type.dart';
import 'models/enum_models.dart';
import 'models/event_list_tab_view_model.dart';
import 'models/home_tab_view_model.dart';
import 'models/my_app_view_model.dart';
import 'models/sunrise_sunset_location_cache.dart';
import 'models/time_provider_result.dart';
import 'models/user_preferences.dart';
import 'models/zorastrian_date.dart';
import 'time_provider.dart';
import 'utilities.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static const _key_theme = "Theme";
  static const _key_theme_color = "ThemeColor";
  static const _key_calendar_type = "PreferredCalendarType";
  static const _key_device_calendar_id = "DeviceCalendarId";

  static const calendar_key_shahenshai = "Shahanshahi";
  static const calendar_key_kadmi = "Kadmi";
  static const calendar_key_fasli = "Fasli";
  static const gatha_days = [
    "Ahunavad",
    "Ushtavad",
    "Spentomad",
    "Vohukhshathra",
    "Vahishtoisht",
    "Avardad-sal-Gah"
  ];

  Database _database;
  List<CalendarType> _calendarTypes;
  List<int> _fasliLeapYears;
  List<String> _mahCollection;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await _initializeDB();
    return _database;
  }

  _initializeDB() async {
    // Construct a file path to copy database to
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "asset_database.db");

    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      // Load database from asset and copy
      ByteData data =
          await rootBundle.load(join('assets', 'calLookupDb.sqlite'));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Save copied asset to documents
      await new File(path).writeAsBytes(bytes);
    }
    return await openDatabase(path);
  }

  Future<List<CalendarType>> get calendarTypes async {
    if (_calendarTypes != null) return _calendarTypes;
    final db = await database;
    final res = await db.query("CalendarType");
    final result = res.isNotEmpty
        ? res.map((e) => CalendarType.fromMap(e)).toList()
        : <CalendarType>[];
    _calendarTypes = result;
    return _calendarTypes;
  }

  Future<List<int>> get fasliLeapYears async {
    if (_fasliLeapYears != null) return _fasliLeapYears;
    final db = await database;
    final result = (await db.rawQuery(
            "SELECT FasliYear FROM CalendarMasterLookup where faslidayid = 366"))
        .map<int>((x) => x["FasliYear"])
        .toList();
    _fasliLeapYears = result;
    return _fasliLeapYears;
  }

  Future<List<String>> get mahCollection async {
    if (_mahCollection != null) return _mahCollection;
    final db = await database;
    final result = (await db.rawQuery('''
      Select a.mahname
      FROM( SELECT Max(id), mahname 
      FROM CalendarDayLookup 
      GROUP BY mahname
      order BY 1) as a''')).map<String>((x) => x["mahname"]).toList();
    _mahCollection = result;
    return _mahCollection;
  }

  Future<List<CalendarEvent>> _getEventsForDay(
      String calendarType, int calendarDayId) async {
    final db = await database;
    final cts = await calendarTypes;

    final calendarTypeId = cts.where((x) => x.name == calendarType).single.id;
    final res = await db.query("CalendarEvent",
        where:
            "calendarDayLookupId = ? AND (calendarTypeId = 4 OR calendarTypeId = ?)",
        whereArgs: [calendarDayId, calendarTypeId]);
    final result = res.isNotEmpty
        ? res.map((e) => CalendarEvent.fromMap(e)).toList()
        : <CalendarEvent>[];
    return result;
  }

  Future<int> _setUserPreference(String name, String value) async {
    final db = await database;
    var result = await db.update(
        "UserPreferences", UserPreference(name: name, value: value).toMap(),
        where: "name = ?", whereArgs: [name]);
    return result;
  }

  Future<List<UserPreference>> _getUserPreferences() async {
    final db = await database;
    String query = '''
      Select * From UserPreferences
      ''';
    final queryResult = await db.rawQuery(query);
    final result = queryResult.isNotEmpty
        ? queryResult.map((e) => UserPreference.fromMap(e)).toList()
        : <UserPreference>[];
    return result;
  }

  Future<ZorastrianDate> getZorastrianDateRaw(CalendarType calendarType,
      String rojName, String mahName, int year) async {
    final db = await database;
    String query = '''
      SELECT CML.id,
      CML.GregorianDate,
      CML.Shahanshahidayid,
      SCDL.RojName AS 'ShahanshahiRojName',
      SCDL.MahName AS 'ShahanshahiMahName',
      CML.ShahanshahiYear,
      CML.KadmiDayId,
      KCDL.RojName AS 'KadmiRojName',
      KCDL.MahName AS 'KadmiMahName',
      CML.KadmiYear,
      CML.faslidayid,
      FCDL.RojName AS 'FasliRojName',
      FCDL.MahName AS 'FasliMahName',
      CML.FasliYear
      FROM CalendarMasterLookup 'CML'
      join CalendarDayLookup 'SCDL' on CML.shahanshahidayid = SCDL.Id
      join CalendarDayLookup 'KCDL' on CML.kadmidayid = KCDL.Id
      join CalendarDayLookup 'FCDL' on CML.faslidayid = FCDL.Id
      ''';
    final whereClause = (calendarType.name == calendar_key_shahenshai)
        ? "where SCDL.RojName = ? AND SCDL.MahName = ? AND CML.ShahanshahiYear = ?"
        : (calendarType.name == calendar_key_kadmi)
            ? "where KCDL.RojName = ? AND KCDL.MahName = ? AND CML.KadmiYear = ?"
            : "where FCDL.RojName = ? AND FCDL.MahName = ? AND CML.FasliYear = ?";
    var queryResult =
        await db.rawQuery(query + whereClause, [rojName, mahName, year]);
    if (queryResult.isEmpty) {
      final lastRowClause =
          (year >= 1470) ? "order by 1 Desc LIMIT 1" : "order by 1 ASC LIMIT 1";
      queryResult = await db.rawQuery(query + lastRowClause);
    }
    final result = ZorastrianDate.fromMap(queryResult.first);
    return result;
  }

  Future<ZorastrianDate> getZorastrianDate(DateTime now) async {
    final db = await database;
    final today = now.toString().substring(0, 10) + " 00:00:00.000";
    String query = '''
      SELECT CML.id,
      CML.GregorianDate,
      CML.Shahanshahidayid,
      SCDL.RojName AS 'ShahanshahiRojName',
      SCDL.MahName AS 'ShahanshahiMahName',
      CML.ShahanshahiYear,
      CML.KadmiDayId,
      KCDL.RojName AS 'KadmiRojName',
      KCDL.MahName AS 'KadmiMahName',
      CML.KadmiYear,
      CML.faslidayid,
      FCDL.RojName AS 'FasliRojName',
      FCDL.MahName AS 'FasliMahName',
      CML.FasliYear
      FROM CalendarMasterLookup 'CML'
      join CalendarDayLookup 'SCDL' on CML.shahanshahidayid = SCDL.Id
      join CalendarDayLookup 'KCDL' on CML.kadmidayid = KCDL.Id
      join CalendarDayLookup 'FCDL' on CML.faslidayid = FCDL.Id
      where CML.gregoriandate = ?
      ''';
    final queryResult = await db.rawQuery(query, [today]);
    final zd = ZorastrianDate.fromMap(queryResult.first);
    final result = zd.copyWith(gregorianDate: now);
    return result;
  }

  String _getGeh(TimeProviderResult timeProviderResult, int dayId) {
    var result = "";
    switch (timeProviderResult.geh) {
      case Geh.Ushahin:
        result = "Ushahin";
        break;
      case Geh.Havan:
        result = "Havan";
        break;
      case Geh.Rapithwan:
        result = (dayId < 211) ? "Rapithwan" : "Second Havan";
        break;
      case Geh.Uzirin:
        result = "Uzirin";
        break;
      case Geh.Aevishuthrem:
        result = "Aiwisruthrem";
        break;
    }
    return result;
  }

  Future<String> _getChog(TimeProviderResult timeProviderResult) async {
    // Good - Amrut, Shubh, Labh, Chal
    // Bad - Udveg, Rog, Kaal
    final db = await database;
    final dateTime = timeProviderResult.dateTime;
    final day = DateFormat.EEEE().format(dateTime);
    final dayPhase = timeProviderResult.dayPhase;
    final chogNumber = timeProviderResult.chogNumber;
    String query = '''
      SELECT ChaughadiaName FROM ChaughadiaLookup
      JOIN Chaughadia on ChaughadiaLookup.ChaugNameId = Chaughadia.ChaughadiaNameId
      WHERE chaugnumber = ? AND dayphase=? AND day = ?
    ''';
    final queryResult = await db.rawQuery(query, [chogNumber, dayPhase, day]);
    final result = queryResult.first["ChaughadiaName"];
    return result;
  }

  Future<List<EventListTabViewModel>> getEventListTabData() async {
    final db = await database;
    String query = '''
      SELECT MIN(cml.GregorianDate) as GregorianDate , ce.Id, ce.title
      FROM CalendarEvent ce
      join CalendarDayLookup cdl on cdl.Id = ce.CalendarDayLookupId
      join CalendarMasterLookup cml on cml.ShahanshahiDayId = cdl.Id
      where cml.GregorianDate > datetime('now','localtime')
      GROUP BY ce.Id, ce.title
      ORDER BY 1 ASC
      ''';
    final queryResult = await db.rawQuery(query);
    final result = queryResult.isEmpty
        ? []
        : queryResult.map((x) => EventListTabViewModel.fromMap(x)).toList();
    return result;
  }

  Future<HomeTabViewModel> getHomeTabData(DateTime now) async {
    DateTime inputDate;
    if (now.hour < 6) {
      // Zorastrian day starts at 6 am.
      inputDate = DateTime(now.year, now.month, now.day - 1, now.hour,
          now.minute, now.second, now.millisecond, now.microsecond);
    } else {
      inputDate = now;
    }
    final zdt = await getZorastrianDate(inputDate);
    final timeProvider = await TimeProvider.getResult(now);
    final sg = _getGeh(timeProvider, zdt.shahanshahiDayId);
    final kg = _getGeh(timeProvider, zdt.kadmiDayId);
    final fg = _getGeh(timeProvider, zdt.fasliDayId);
    final ch = await _getChog(timeProvider);
    final se =
        await _getEventsForDay(calendar_key_shahenshai, zdt.shahanshahiDayId);
    final ke = await _getEventsForDay(calendar_key_kadmi, zdt.kadmiDayId);
    final fe = await _getEventsForDay(calendar_key_fasli, zdt.fasliDayId);
    return HomeTabViewModel(
      zorastrianDate: zdt,
      shahanshahiGeh: sg,
      kadmiGeh: kg,
      fasliGeh: fg,
      chog: ch,
      shahanshahiEvents: se,
      kadmiEvents: ke,
      fasliEvents: fe,
    );
  }

  Future<int> setThemeColorPreference(MaterialColor color) async {
    final colorStr = color.toMaterialColorName();
    return await _setUserPreference(_key_theme_color, colorStr);
  }

  Future<int> setTheme(ThemeMode input) async {
    String themeStr = "";
    switch (input) {
      case ThemeMode.light:
        themeStr = "light";
        break;
      case ThemeMode.dark:
        themeStr = "dark";
        break;
      case ThemeMode.system:
      default:
        themeStr = "system";
        break;
    }
    return await _setUserPreference(_key_theme, themeStr);
  }

  Future<int> setPreferredCalendar(CalendarType input) async {
    final inputStr = input.id.toString();
    return await _setUserPreference(_key_calendar_type, inputStr);
  }

  Future<void> saveEvent(CalendarEvent input) async {
    final db = await database;
    if (input.id == 0) {
      final queryResult =
          await db.rawQuery("SELECT MAX(id)+1 as id FROM CalendarEvent");
      final int id = queryResult.first["id"];
      await db.insert("CalendarEvent", input.copyWith(id: id).toMap());
    } else {
      await db.update("CalendarEvent", input.toMap(),
          where: "id=?", whereArgs: [input.id]);
    }
  }

  Future<void> deleteEvent(CalendarEvent input) async {
    final db = await database;
    db.delete("CalendarEvent", where: "id = ?", whereArgs: [input.id]);
  }

  Future<MyAppViewModel> getMyAppData() async {
    final preferences = await _getUserPreferences();

    final color = preferences
        .where((x) => x.name == _key_theme_color)
        .single
        .value
        .toMaterialColor();

    final themeStr = preferences
        .where((x) => x.name == _key_theme)
        .single
        .value
        .toLowerCase();

    final themeMode = (themeStr == "light")
        ? ThemeMode.light
        : (themeStr == "dark")
            ? ThemeMode.dark
            : ThemeMode.system;

    final cts = await calendarTypes;
    final pct = int.parse(
        preferences.where((x) => x.name == _key_calendar_type).single.value);
    final calendarType = cts.where((x) => x.id == pct).single;
    final deviceCalendarState = preferences
        .where((x) => x.name == _key_device_calendar_id)
        .single
        .value
        .toDeviceCalendarState();
    return MyAppViewModel(
        themeColor: color,
        themeMode: themeMode,
        calendarType: calendarType,
        deviceCalendarState: deviceCalendarState);
  }

  Future<List<String>> getRojNamesForCalendarMah(
      String mahName, String calendarName, int year) async {
    final db = await database;
    int daysInYear = 365;
    if (calendarName == calendar_key_fasli) {
      final fly = await fasliLeapYears;
      if (fly.contains(year)) {
        daysInYear = 366;
      }
    }
    final rc = (await db.rawQuery('''
      SELECT rojname FROM CalendarDayLookup 
      where id <=? and mahname = ?
    ''', [daysInYear, mahName])).map<String>((x) => x["RojName"]).toList();
    return rc;
  }

  Future<List<SunriseSunsetLocationCache>> getSunriseSunsetLocationCache(
      DateTime dateTime) async {
    final db = await database;
    final date =
        DateTime(dateTime.year, dateTime.month, dateTime.day).toIso8601String();
    final query = await db.rawQuery('''
      SELECT * FROM SunriseSunsetLocationCache 
      where Date =?
    ''', [date]);
    final result = (query.isEmpty)
        ? <SunriseSunsetLocationCache>[]
        : query.map((x) => SunriseSunsetLocationCache.fromMap(x)).toList();
    return result;
  }

  Future<void> setSunriseSunsetLocationCache(
      SunriseSunsetLocationCache input) async {
    final db = await database;
    final dateTime = input.date;
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final data = input.copyWith(date: date);
    await db.insert("SunriseSunsetLocationCache", data.toMap());
  }

  Future<int> setDeviceCalendarId(String deviceCalendarId) async {
    return await _setUserPreference(_key_device_calendar_id, deviceCalendarId);
  }

  Future<DeviceCalendarState> getDeviceCalendarState() async {
    final preferences = await _getUserPreferences();
    final result = preferences
        .where((x) => x.name == _key_device_calendar_id)
        .single
        .value
        .toDeviceCalendarState();
    return result;
  }

  Future<String> getDeviceCalendarId() async {
    final preferences = await _getUserPreferences();
    final result = preferences
        .where((x) => x.name == _key_device_calendar_id)
        .single
        .value;
    return result;
  }

  Future<List<MapEntry<ZorastrianDate, List<CalendarEvent>>>> getMonthTabData(
      DateTime selectedDate,
      String calendarType,
      MonthTabCalendarMode mode) async {
    final db = await database;
    List<Map<String, dynamic>> queryResult;
    if (mode == MonthTabCalendarMode.Zoroastrian) {
      final today = selectedDate.toString().substring(0, 10) + " 00:00:00.000";
      final shahanshahiJoinClause = '''
      join CalendarDayLookup 'BaseCDL' on BaseCML.shahanshahidayid = BaseCDL.Id
      join CalendarDayLookup 'RangeCDL' on RangeCDL.MahName = BaseCDL.MahName AND RangeCDL.Id != 366
      join CalendarMasterLookup CML on CML.shahanshahidayid = RangeCDL.Id AND BaseCML.ShahanshahiYear = CML.ShahanshahiYear
      ''';
      final kadmiJoinClause = '''
      join CalendarDayLookup 'BaseCDL' on BaseCML.kadmidayid = BaseCDL.Id
      join CalendarDayLookup 'RangeCDL' on RangeCDL.MahName = BaseCDL.MahName AND RangeCDL.Id != 366
      join CalendarMasterLookup CML on CML.kadmidayid = RangeCDL.Id AND BaseCML.KadmiYear = CML.KadmiYear
      ''';
      final fasliJoinClause = '''
      join CalendarDayLookup 'BaseCDL' on BaseCML.faslidayid = BaseCDL.Id
      join CalendarDayLookup 'RangeCDL' on RangeCDL.MahName = BaseCDL.MahName
      join CalendarMasterLookup CML on CML.faslidayid = RangeCDL.Id AND BaseCML.FasliYear = CML.FasliYear
      ''';
      final joinClause = calendarPicker(calendarType, shahanshahiJoinClause,
          kadmiJoinClause, fasliJoinClause);
      final query = '''
      SELECT CML.id,
      CML.GregorianDate,
      CML.Shahanshahidayid,
      SCDL.RojName AS 'ShahanshahiRojName',
      SCDL.MahName AS 'ShahanshahiMahName',
      CML.ShahanshahiYear,
      CML.KadmiDayId,
      KCDL.RojName AS 'KadmiRojName',
      KCDL.MahName AS 'KadmiMahName',
      CML.KadmiYear,
      CML.faslidayid,
      FCDL.RojName AS 'FasliRojName',
      FCDL.MahName AS 'FasliMahName',
      CML.FasliYear
      FROM CalendarMasterLookup 'BaseCML' 
      $joinClause
      join CalendarDayLookup 'SCDL' on CML.shahanshahidayid = SCDL.Id
      join CalendarDayLookup 'KCDL' on CML.kadmidayid = KCDL.Id
      join CalendarDayLookup 'FCDL' on CML.faslidayid = FCDL.Id
      where BaseCML.gregoriandate = ?
      ''';
      queryResult = await db.rawQuery(query, [today]);
    } else if (mode == MonthTabCalendarMode.Gregorian) {
      final fromDate = DateTime(selectedDate.year, selectedDate.month, 1);
      final toDate = DateTime(selectedDate.year, selectedDate.month + 1, 0);
      String query = '''
      SELECT CML.id,
      CML.GregorianDate,
      CML.Shahanshahidayid,
      SCDL.RojName AS 'ShahanshahiRojName',
      SCDL.MahName AS 'ShahanshahiMahName',
      CML.ShahanshahiYear,
      CML.KadmiDayId,
      KCDL.RojName AS 'KadmiRojName',
      KCDL.MahName AS 'KadmiMahName',
      CML.KadmiYear,
      CML.faslidayid,
      FCDL.RojName AS 'FasliRojName',
      FCDL.MahName AS 'FasliMahName',
      CML.FasliYear
      FROM CalendarMasterLookup 'CML'
      join CalendarDayLookup 'SCDL' on CML.shahanshahidayid = SCDL.Id
      join CalendarDayLookup 'KCDL' on CML.kadmidayid = KCDL.Id
      join CalendarDayLookup 'FCDL' on CML.faslidayid = FCDL.Id
      where CML.gregoriandate >= ? AND CML.gregoriandate <= ?
      ''';
      queryResult = await db.rawQuery(query, [fromDate, toDate]);
    }
    final zorastrianDateList =
        queryResult.map((e) => ZorastrianDate.fromMap(e)).toList();

    final result = List<MapEntry<ZorastrianDate, List<CalendarEvent>>>.empty(
        growable: true);

    await Future.forEach(zorastrianDateList, (e) async {
      final eventList = await _getEventsForDay(
          calendarType,
          calendarPicker(
              calendarType, e.shahanshahiDayId, e.kadmiDayId, e.fasliDayId));
      result.add(MapEntry(e, eventList));
    });

    return result;
  }
}
