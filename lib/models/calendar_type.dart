// To parse this JSON data, do
//
//     final calendarType = calendarTypeFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

CalendarType calendarTypeFromJson(String str) =>
    CalendarType.fromMap(json.decode(str));

String calendarTypeToJson(CalendarType data) => json.encode(data.toMap());

class CalendarType extends Equatable {
  final int id;
  final String name;

  const CalendarType({
    this.id,
    this.name,
  });

  factory CalendarType.fromMap(Map<String, dynamic> json) => CalendarType(
        id: json["Id"],
        name: json["Name"],
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "Name": name,
      };

  @override
  List<Object> get props => [id, name];
}
