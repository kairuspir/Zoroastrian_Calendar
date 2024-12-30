// To parse this JSON data, do
//
//     final calendarEvent = calendarEventFromJson(jsonString);

import 'dart:convert';

CalendarEvent calendarEventFromJson(String str) =>
    CalendarEvent.fromMap(json.decode(str));

String calendarEventToJson(CalendarEvent data) => json.encode(data.toMap());

class CalendarEvent {
  final int id;
  final int calendarMasterLookupId;
  final int calendarDayLookupId;
  final int calendarTypeId;
  final String title;
  final String description;
  final String deviceCalendarEventId;
  final int isDeleted;

  const CalendarEvent({
    required this.id,
    required this.calendarMasterLookupId,
    required this.calendarDayLookupId,
    required this.calendarTypeId,
    required this.title,
    required this.description,
    required this.deviceCalendarEventId,
    required this.isDeleted,
  });

  CalendarEvent copyWith({
    int? id,
    int? calendarMasterLookupId,
    int? calendarDayLookupId,
    int? calendarTypeId,
    String? title,
    String? description,
    String? deviceCalendarEventId,
    int? isDeleted,
  }) {
    return CalendarEvent(
        id: id ?? this.id,
        calendarMasterLookupId:
            calendarMasterLookupId ?? this.calendarMasterLookupId,
        calendarDayLookupId: calendarDayLookupId ?? this.calendarDayLookupId,
        calendarTypeId: calendarTypeId ?? this.calendarTypeId,
        title: title ?? this.title,
        description: description ?? this.description,
        deviceCalendarEventId:
            deviceCalendarEventId ?? this.deviceCalendarEventId,
        isDeleted: isDeleted ?? this.isDeleted);
  }

  factory CalendarEvent.fromMap(Map<String, dynamic> json) => CalendarEvent(
        id: json["Id"],
        calendarMasterLookupId: json["CalendarMasterLookupId"],
        calendarDayLookupId: json["CalendarDayLookupId"],
        calendarTypeId: json["CalendarTypeId"],
        title: json["Title"],
        description: json["Description"],
        deviceCalendarEventId: json["DeviceCalendarEventId"],
        isDeleted: json["IsDeleted"],
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "CalendarMasterLookupId": calendarMasterLookupId,
        "CalendarDayLookupId": calendarDayLookupId,
        "CalendarTypeId": calendarTypeId,
        "Title": title,
        "Description": description,
        "DeviceCalendarEventId": deviceCalendarEventId,
        "IsDeleted": isDeleted,
      };
}
