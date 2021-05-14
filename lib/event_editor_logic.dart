import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zoroastriancalendar/models/enum_models.dart';

import 'database.dart';
import 'device_calendar_provider.dart';
import 'models/calendar_event.dart';
import 'models/calendar_type.dart';
import 'models/event_editor_model.dart';
import 'models/event_editor_view_model.dart';
import 'models/zorastrian_date.dart';
import 'utilities.dart';

class EventEditorLogic {
  EventEditorModel _eventEditorModel;

  Future saveEventToDeviceCalendar() async {
    if ((await DBProvider.db.getDeviceCalendarState()) ==
        DeviceCalendarState.Initialized) {
      final deviceCalendarId = await DBProvider.db.getDeviceCalendarId();
      var eventId = _eventEditorModel.calendarEvent.deviceCalendarEventId;
      if (!(await DeviceCalendarProvider.isEventPresentInCalendar(
          deviceCalendarId, eventId))) {
        eventId = null;
      }
      final event = Event(deviceCalendarId,
          eventId: eventId,
          title: _eventEditorModel.calendarEvent.title,
          description: _eventEditorModel.calendarEvent.description,
          start: _eventEditorModel.zorastrianDate.gregorianDate,
          end: _eventEditorModel.zorastrianDate.gregorianDate,
          allDay: true,
          recurrenceRule:
              RecurrenceRule(RecurrenceFrequency.Daily, interval: 365));
      final upsertEventResult =
          await DeviceCalendarProvider.createOrUpdateEvent(event);
      final _devCalEventId = upsertEventResult.data;
      if (_devCalEventId !=
          _eventEditorModel.calendarEvent.deviceCalendarEventId) {
        final newCalendarEvent = _eventEditorModel.calendarEvent
            .copyWith(deviceCalendarEventId: _devCalEventId);
        _eventEditorModel =
            _eventEditorModel.copyWith(calendarEvent: newCalendarEvent);
      }
    }
  }

  Future saveEventEditorEvent() async {
    await DBProvider.db.saveEvent(_eventEditorModel.calendarEvent);
  }

  void clearEventEditorState() {
    _eventEditorModel = null;
  }

  void setEventEditorState({
    @required EditorMode editorTitle,
    @required ZorastrianDate zorastrianDate,
    @required CalendarEvent calendarEvent,
  }) {
    _eventEditorModel = EventEditorModel(
        editorTitle: editorTitle,
        calendarEvent: calendarEvent,
        zorastrianDate: zorastrianDate);
  }

  void setEventEditorEventTitle(String title) {
    final newCalendarEvent =
        _eventEditorModel.calendarEvent.copyWith(title: title);

    _eventEditorModel =
        _eventEditorModel.copyWith(calendarEvent: newCalendarEvent);
  }

  void setEventEditorCalendarType(CalendarType calendarType) {
    final zd = _eventEditorModel.zorastrianDate;
    final newCalendarDayLookupId = zd.getDayId(calendarType.name);
    final newCalendarTypeId = calendarType.id;
    final newCalendarEvent = _eventEditorModel.calendarEvent.copyWith(
        calendarDayLookupId: newCalendarDayLookupId,
        calendarTypeId: newCalendarTypeId);
    _eventEditorModel =
        _eventEditorModel.copyWith(calendarEvent: newCalendarEvent);
  }

  Future setEventEditorMah(String mahName) async {
    final calendarType = (await DBProvider.db.calendarTypes)
        .where((x) => x.id == _eventEditorModel.calendarEvent.calendarTypeId)
        .single;

    final oldMahName =
        _eventEditorModel.zorastrianDate.getMahName(calendarType.name);
    final newMahName = mahName;
    if (oldMahName == newMahName) return;

    String rojName =
        _eventEditorModel.zorastrianDate.getRojName(calendarType.name);

    if (DBProvider.gatha_days.contains(rojName) &&
        newMahName != "Asfandarmad") {
      rojName = "Hormazd";
    }

    final year = _eventEditorModel.zorastrianDate.getYear(calendarType.name);

    final newZorastrianDate = await DBProvider.db
        .getZorastrianDateRaw(calendarType, rojName, mahName, year);
    final newCalendarDayLookupId =
        newZorastrianDate.getDayId(calendarType.name);
    final newCalendarMasterLookupId = newZorastrianDate.id;
    final newCalendarEvent = _eventEditorModel.calendarEvent.copyWith(
        calendarDayLookupId: newCalendarDayLookupId,
        calendarMasterLookupId: newCalendarMasterLookupId);
    _eventEditorModel = _eventEditorModel.copyWith(
        calendarEvent: newCalendarEvent, zorastrianDate: newZorastrianDate);
  }

  Future setEventEditorRoj(String rojName) async {
    final calendarType = (await DBProvider.db.calendarTypes)
        .where((x) => x.id == _eventEditorModel.calendarEvent.calendarTypeId)
        .single;
    final mahName =
        _eventEditorModel.zorastrianDate.getMahName(calendarType.name);
    final year = _eventEditorModel.zorastrianDate.getYear(calendarType.name);

    final newZorastrianDate = await DBProvider.db
        .getZorastrianDateRaw(calendarType, rojName, mahName, year);
    final newCalendarDayLookupId =
        newZorastrianDate.getDayId(calendarType.name);
    final newCalendarMasterLookupId = newZorastrianDate.id;
    final newCalendarEvent = _eventEditorModel.calendarEvent.copyWith(
        calendarDayLookupId: newCalendarDayLookupId,
        calendarMasterLookupId: newCalendarMasterLookupId);

    _eventEditorModel = _eventEditorModel.copyWith(
        calendarEvent: newCalendarEvent, zorastrianDate: newZorastrianDate);
  }

  Future setEventEditorYear(int year) async {
    final calendarType = (await DBProvider.db.calendarTypes)
        .where((x) => x.id == _eventEditorModel.calendarEvent.calendarTypeId)
        .single;
    final mahName =
        _eventEditorModel.zorastrianDate.getMahName(calendarType.name);
    final rojName =
        _eventEditorModel.zorastrianDate.getRojName(calendarType.name);
    final newZorastrianDate = await DBProvider.db
        .getZorastrianDateRaw(calendarType, rojName, mahName, year);
    final newCalendarDayLookupId =
        newZorastrianDate.getDayId(calendarType.name);
    final newCalendarMasterLookupId = newZorastrianDate.id;
    final newCalendarEvent = _eventEditorModel.calendarEvent.copyWith(
        calendarDayLookupId: newCalendarDayLookupId,
        calendarMasterLookupId: newCalendarMasterLookupId);
    _eventEditorModel = _eventEditorModel.copyWith(
        calendarEvent: newCalendarEvent, zorastrianDate: newZorastrianDate);
  }

  Future setEventEditorDate(DateTime date) async {
    final input = DateTime(date.year, date.month, date.day);
    final calendarType = (await DBProvider.db.calendarTypes)
        .where((x) => x.id == _eventEditorModel.calendarEvent.calendarTypeId)
        .single;
    final newZorastrianDate = await DBProvider.db.getZorastrianDate(input);
    final newCalendarDayLookupId =
        newZorastrianDate.getDayId(calendarType.name);
    final newCalendarMasterLookupId = newZorastrianDate.id;
    final newCalendarEvent = _eventEditorModel.calendarEvent.copyWith(
        calendarDayLookupId: newCalendarDayLookupId,
        calendarMasterLookupId: newCalendarMasterLookupId);
    _eventEditorModel = _eventEditorModel.copyWith(
        calendarEvent: newCalendarEvent, zorastrianDate: newZorastrianDate);
  }

  Future<EventEditorViewModel> getEventEditorData() async {
    final String editorTitle = (_eventEditorModel.editorTitle == EditorMode.Add)
        ? "Add Event"
        : "Edit Event";
    final ZorastrianDate zorastrianDate = _eventEditorModel.zorastrianDate;
    final CalendarEvent calendarEvent = _eventEditorModel.calendarEvent;

    final eventTitle = calendarEvent.title;
    final cts = await DBProvider.db.calendarTypes;
    final selectedCalendarType =
        cts.where((x) => x.id == calendarEvent.calendarTypeId).single;
    final selectedCalendarTypeName = selectedCalendarType.name;

    final selectedMah = zorastrianDate.getMahName(selectedCalendarTypeName);
    final selectedRoj = zorastrianDate.getRojName(selectedCalendarTypeName);
    final selectedYear = zorastrianDate.getYear(selectedCalendarTypeName);

    final selectedDate = zorastrianDate.gregorianDate;

    final rc = await DBProvider.db.getRojNamesForCalendarMah(
        selectedMah, selectedCalendarTypeName, selectedYear);
    final mc = await DBProvider.db.mahCollection;
    return EventEditorViewModel(
      calendarTypes: cts,
      mahCollection: mc,
      rojCollection: rc,
      selectedMah: selectedMah,
      selectedRoj: selectedRoj,
      selectedYear: selectedYear,
      selectedCalendarType: selectedCalendarType,
      selectedDate: selectedDate,
      eventTitle: eventTitle,
      editorTitle: editorTitle,
    );
  }

  Future<void> deleteEvent(CalendarEvent input) async {
    await DBProvider.db.deleteEvent(input);
  }

  Future<void> initializeDeviceCalendar() async {
    final calendars = (await DeviceCalendarProvider.retrieveCalendars()).data;
    final devCal = calendars.where((calendar) =>
        calendar.name == DeviceCalendarProvider.local_account_name);

    final deviceCalendarId = (devCal.isNotEmpty)
        ? devCal.first.id
        : (await DeviceCalendarProvider.createCalendar(
                DeviceCalendarProvider.local_account_name, Colors.red))
            .data;
    await DBProvider.db.setDeviceCalendarId(deviceCalendarId);
  }
}
