import 'package:flutter/material.dart';
import 'calendar_type.dart';

class MyAppViewModel {
  final MaterialColor themeColor;
  final ThemeMode themeMode;
  final CalendarType calendarType;

  const MyAppViewModel({
    required this.themeColor,
    required this.themeMode,
    required this.calendarType,
  });
}
