import 'package:flutter/foundation.dart';

import 'calendar_type.dart';

class EventEditorViewModel {
  final List<String> rojCollection;
  final List<String> mahCollection;
  final List<CalendarType> calendarTypes;
  final List<String> frequencyCollection;

  final String editorTitle;
  final String eventTitle;
  final CalendarType selectedCalendarType;
  final String selectedRoj;
  final String selectedMah;
  final int selectedYear;
  final String selectedFrequency;
  final DateTime selectedDate;

  const EventEditorViewModel({
    @required this.rojCollection,
    @required this.mahCollection,
    @required this.calendarTypes,
    @required this.frequencyCollection,
    @required this.selectedRoj,
    @required this.selectedMah,
    @required this.selectedYear,
    @required this.selectedFrequency,
    @required this.selectedCalendarType,
    @required this.selectedDate,
    @required this.eventTitle,
    @required this.editorTitle,
  });
}
