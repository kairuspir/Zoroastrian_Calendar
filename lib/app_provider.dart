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

  const AppProvider({
    required this.themeColor,
    required this.themeMode,
    required this.calendarType,
    required this.deviceCalendarState,
    required this.callSetState,
    required this.child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(AppProvider oldWidget) {
    return oldWidget.themeColor != themeColor ||
        oldWidget.themeMode != themeMode ||
        oldWidget.calendarType != calendarType ||
        oldWidget.deviceCalendarState != deviceCalendarState ||
        oldWidget.callSetState != callSetState;
  }

  static AppProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppProvider>();
}
