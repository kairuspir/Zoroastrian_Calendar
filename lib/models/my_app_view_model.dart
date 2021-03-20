import 'package:flutter/material.dart';
import 'calendar_type.dart';
import 'enum_models.dart';

class MyAppViewModel {
  final MaterialColor themeColor;
  final ThemeMode themeMode;
  final CalendarType calendarType;
  final DeviceCalendarState deviceCalendarState;

  const MyAppViewModel({
    @required this.themeColor,
    @required this.themeMode,
    @required this.calendarType,
    @required this.deviceCalendarState,
  });
}
