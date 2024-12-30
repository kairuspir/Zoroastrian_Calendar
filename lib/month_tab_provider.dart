import 'package:flutter/widgets.dart';
import 'package:zoroastriancalendar/models/enum_models.dart';

class MonthTabProvider extends InheritedWidget {
  final MonthTabCalendarMode mode;
  final Widget child;

  MonthTabProvider({required this.mode, required this.child})
      : super(child: child);
  @override
  bool updateShouldNotify(MonthTabProvider oldWidget) {
    return true;
  }

  static MonthTabProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MonthTabProvider>();
}
