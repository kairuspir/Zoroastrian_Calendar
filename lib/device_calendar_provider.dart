import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';

class DeviceCalendarProvider {
  static final _deviceCalendarPlugin = DeviceCalendarPlugin();
  static const local_account_name = "Zoroastrian Calendar";

  static Future<Result<UnmodifiableListView<Calendar>>>
      retrieveCalendars() async {
    Result<UnmodifiableListView<Calendar>> result;
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
          result = Result<UnmodifiableListView<Calendar>>();
        }
      }

      result = await _deviceCalendarPlugin.retrieveCalendars();
    } on PlatformException catch (e) {
      print(e);
      result = Result<UnmodifiableListView<Calendar>>();
    }
    return result;
  }

  static Future<Result<String>> createCalendar(
      String calendarName, Color calendarColor) async {
    return await _deviceCalendarPlugin.createCalendar(
      calendarName,
      calendarColor: calendarColor,
      localAccountName: local_account_name,
    );
  }

  static Future<Result<String>?> createOrUpdateEvent(Event event) async {
    DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
    return await _deviceCalendarPlugin.createOrUpdateEvent(event);
  }

  static Future<bool> isPermissionsGranted() async {
    var result = true;
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        result = false;
      }
    }
    return result;
  }

  static Future<bool> isEventPresentInCalendar(
      String calendarId, String? eventId) async {
    var result = false;
    if (eventId != null) {
      RetrieveEventsParams retrieveEventsParams =
          RetrieveEventsParams(eventIds: [eventId]);
      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
          calendarId, retrieveEventsParams);
      result = eventsResult.data!.isNotEmpty;
    }
    return result;
  }
}
