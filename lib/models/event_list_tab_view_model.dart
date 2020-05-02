// To parse this JSON data, do
//
//     final eventListTabViewModel = eventListTabViewModelFromJson(jsonString);

import 'dart:convert';

EventListTabViewModel eventListTabViewModelFromJson(String str) =>
    EventListTabViewModel.fromMap(json.decode(str));

String eventListTabViewModelToJson(EventListTabViewModel data) =>
    json.encode(data.toMap());

class EventListTabViewModel {
  final int id;
  final DateTime gregorianDate;
  final String title;

  EventListTabViewModel({
    this.id,
    this.gregorianDate,
    this.title,
  });

  EventListTabViewModel copyWith({
    int id,
    DateTime gregorianDate,
    String title,
  }) =>
      EventListTabViewModel(
        id: id ?? this.id,
        gregorianDate: gregorianDate ?? this.gregorianDate,
        title: title ?? this.title,
      );

  factory EventListTabViewModel.fromMap(Map<String, dynamic> json) =>
      EventListTabViewModel(
        id: json["Id"],
        gregorianDate: DateTime.parse(json["GregorianDate"]),
        title: json["Title"],
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "GregorianDate": gregorianDate,
        "Title": title,
      };
}
