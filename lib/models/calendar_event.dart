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
  final int isDeleted;

  const CalendarEvent({
    this.id,
    this.calendarMasterLookupId,
    this.calendarDayLookupId,
    this.calendarTypeId,
    this.title,
    this.description,
    this.isDeleted,
  });

  CalendarEvent copyWith({
    int id,
    int calendarMasterLookupId,
    int calendarDayLookupId,
    int calendarTypeId,
    String title,
    String description,
    int isDeleted,
  }) {
    return CalendarEvent(
        id: id ?? this.id,
        calendarMasterLookupId:
            calendarMasterLookupId ?? this.calendarMasterLookupId,
        calendarDayLookupId: calendarDayLookupId ?? this.calendarDayLookupId,
        calendarTypeId: calendarTypeId ?? this.calendarTypeId,
        title: title ?? this.title,
        description: description ?? this.description,
        isDeleted: isDeleted ?? this.isDeleted);
  }

  factory CalendarEvent.fromMap(Map<String, dynamic> json) => CalendarEvent(
        id: json["Id"],
        calendarMasterLookupId: json["CalendarMasterLookupId"],
        calendarDayLookupId: json["CalendarDayLookupId"],
        calendarTypeId: json["CalendarTypeId"],
        title: json["Title"],
        description: json["Description"],
        isDeleted: json["IsDeleted"],
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "CalendarMasterLookupId": calendarMasterLookupId,
        "CalendarDayLookupId": calendarDayLookupId,
        "CalendarTypeId": calendarTypeId,
        "Title": title,
        "Description": description,
        "IsDeleted": isDeleted,
      };
}
