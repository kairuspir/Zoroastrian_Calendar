import 'package:flutter/foundation.dart';

import 'calendar_event.dart';
import 'zorastrian_date.dart';

class EventEditorModel {
  final EditorMode editorTitle;
  final ZorastrianDate zorastrianDate;
  final CalendarEvent calendarEvent;
  final Frequency selectedFrequency;

  const EventEditorModel(
      {@required this.editorTitle,
      @required this.calendarEvent,
      @required this.zorastrianDate,
      @required this.selectedFrequency});

  EventEditorModel copyWith(
          {EditorMode editorTitle,
          CalendarEvent calendarEvent,
          ZorastrianDate zorastrianDate,
          Frequency selectedFrequency}) =>
      EventEditorModel(
        editorTitle: editorTitle ?? this.editorTitle,
        calendarEvent: calendarEvent ?? this.calendarEvent,
        zorastrianDate: zorastrianDate ?? this.zorastrianDate,
        selectedFrequency: selectedFrequency ?? this.selectedFrequency,
      );
}

enum EditorMode { Add, Edit }
enum Frequency { Yearly, Monthly }
