import 'package:flutter/material.dart';

import 'models/calendar_type.dart';

class AppProvider extends InheritedWidget {
  final MaterialColor themeColor;
  final ThemeMode themeMode;
  final CalendarType calendarType;
  final Function callSetState;

  const AppProvider({
    super.key,
    required this.themeColor,
    required this.themeMode,
    required this.calendarType,
    required this.callSetState,
    required super.child,
  });

  @override
  bool updateShouldNotify(AppProvider oldWidget) {
    return oldWidget.themeColor != themeColor ||
        oldWidget.themeMode != themeMode ||
        oldWidget.calendarType != calendarType ||
        oldWidget.callSetState != callSetState;
  }

  static AppProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppProvider>();
}
