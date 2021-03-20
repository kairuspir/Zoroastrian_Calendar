import 'package:flutter/material.dart';

import 'models/calendar_type.dart';
import 'models/enum_models.dart';

class AppProvider extends InheritedWidget {
  final MaterialColor themeColor;
  final ThemeMode themeMode;
  final CalendarType calendarType;
  final DeviceCalendarState deviceCalendarState;
  final Function callSetState;
  final Widget child;

  AppProvider({
    this.themeColor,
    this.themeMode,
    this.calendarType,
    this.deviceCalendarState,
    this.callSetState,
    this.child,
  });

  @override
  bool updateShouldNotify(AppProvider oldWidget) {
    return true;
  }

  static AppProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppProvider>();
}
