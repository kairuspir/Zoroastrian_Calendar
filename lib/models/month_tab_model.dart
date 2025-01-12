import 'enum_models.dart';

class MonthTabModel {
  final MonthTabCalendarMode mode;
  final DateTime selectedDate;
  final String calendarType;

  const MonthTabModel(
      {required this.mode,
      required this.selectedDate,
      required this.calendarType});

  MonthTabModel copyWith(
          {MonthTabCalendarMode? mode,
          DateTime? selectedDate,
          String? calendarType}) =>
      MonthTabModel(
        mode: mode ?? this.mode,
        selectedDate: selectedDate ?? this.selectedDate,
        calendarType: calendarType ?? this.calendarType,
      );
}
