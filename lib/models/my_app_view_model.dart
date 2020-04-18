import 'package:flutter/material.dart';
import 'calendar_type.dart';

class MyAppViewModel {
  final MaterialColor themeColor;
  final ThemeMode themeMode;
  final CalendarType calendarType;

  const MyAppViewModel({this.themeColor, this.themeMode, this.calendarType});
}
