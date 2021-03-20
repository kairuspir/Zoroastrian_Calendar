import 'package:flutter/foundation.dart';

import 'calendar_event.dart';
import 'zorastrian_date.dart';

class EventEditorModel {
  final EditorMode editorTitle;
  final ZorastrianDate zorastrianDate;
  final CalendarEvent calendarEvent;

  const EventEditorModel(
      {@required this.editorTitle,
      @required this.calendarEvent,
      @required this.zorastrianDate});

  EventEditorModel copyWith(
          {EditorMode editorTitle,
          CalendarEvent calendarEvent,
          ZorastrianDate zorastrianDate,
          bool useDeviceCalendar}) =>
      EventEditorModel(
        editorTitle: editorTitle ?? this.editorTitle,
        calendarEvent: calendarEvent ?? this.calendarEvent,
        zorastrianDate: zorastrianDate ?? this.zorastrianDate,
      );
}

enum EditorMode { Add, Edit }
