import 'package:flutter/widgets.dart';
import 'package:zoroastriancalendar/models/enum_models.dart';

class MonthTabProvider extends InheritedWidget {
  final MonthTabCalendarMode mode;

  const MonthTabProvider({super.key, required this.mode, required super.child});
  @override
  bool updateShouldNotify(MonthTabProvider oldWidget) {
    return true;
  }

  static MonthTabProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MonthTabProvider>();
}
