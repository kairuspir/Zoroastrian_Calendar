// To parse this JSON data, do
//
//     final zorastrianDate = zorastrianDateFromJson(jsonString);

import 'dart:convert';

ZorastrianDate zorastrianDateFromJson(String str) =>
    ZorastrianDate.fromMap(json.decode(str));

String zorastrianDateToJson(ZorastrianDate data) => json.encode(data.toMap());

class ZorastrianDate {
  final int id;
  final DateTime gregorianDate;
  final int shahanshahiDayId;
  final String shahanshahiRojName;
  final String shahanshahiMahName;
  final int shahanshahiYear;
  final int kadmiDayId;
  final String kadmiRojName;
  final String kadmiMahName;
  final int kadmiYear;
  final int fasliDayId;
  final String fasliRojName;
  final String fasliMahName;
  final int fasliYear;

  const ZorastrianDate({
    required this.id,
    required this.gregorianDate,
    required this.shahanshahiDayId,
    required this.shahanshahiRojName,
    required this.shahanshahiMahName,
    required this.shahanshahiYear,
    required this.kadmiDayId,
    required this.kadmiRojName,
    required this.kadmiMahName,
    required this.kadmiYear,
    required this.fasliDayId,
    required this.fasliRojName,
    required this.fasliMahName,
    required this.fasliYear,
  });

  ZorastrianDate copyWith({
    int? id,
    DateTime? gregorianDate,
    int? shahanshahiDayId,
    String? shahanshahiRojName,
    String? shahanshahiMahName,
    int? shahanshahiYear,
    int? kadmiDayId,
    String? kadmiRojName,
    String? kadmiMahName,
    int? kadmiYear,
    int? fasliDayId,
    String? fasliRojName,
    String? fasliMahName,
    int? fasliYear,
  }) {
    return ZorastrianDate(
      id: id ?? this.id,
      gregorianDate: gregorianDate ?? this.gregorianDate,
      shahanshahiDayId: shahanshahiDayId ?? this.shahanshahiDayId,
      shahanshahiRojName: shahanshahiRojName ?? this.shahanshahiRojName,
      shahanshahiMahName: shahanshahiMahName ?? this.shahanshahiMahName,
      shahanshahiYear: shahanshahiYear ?? this.shahanshahiYear,
      kadmiDayId: kadmiDayId ?? this.kadmiDayId,
      kadmiRojName: kadmiRojName ?? this.kadmiRojName,
      kadmiMahName: kadmiMahName ?? this.kadmiMahName,
      kadmiYear: kadmiYear ?? this.kadmiYear,
      fasliDayId: fasliDayId ?? this.fasliDayId,
      fasliRojName: fasliRojName ?? this.fasliRojName,
      fasliMahName: fasliMahName ?? this.fasliMahName,
      fasliYear: fasliYear ?? this.fasliYear,
    );
  }

  factory ZorastrianDate.fromMap(Map<String, dynamic> json) => ZorastrianDate(
        id: json["Id"],
        gregorianDate: DateTime.parse(json["GregorianDate"]),
        shahanshahiDayId: json["ShahanshahiDayId"],
        shahanshahiRojName: json["ShahanshahiRojName"],
        shahanshahiMahName: json["ShahanshahiMahName"],
        shahanshahiYear: json["ShahanshahiYear"],
        kadmiDayId: json["KadmiDayId"],
        kadmiRojName: json["KadmiRojName"],
        kadmiMahName: json["KadmiMahName"],
        kadmiYear: json["KadmiYear"],
        fasliDayId: json["FasliDayId"],
        fasliRojName: json["FasliRojName"],
        fasliMahName: json["FasliMahName"],
        fasliYear: json["FasliYear"],
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "GregorianDate": gregorianDate.toIso8601String(),
        "ShahanshahiDayId": shahanshahiDayId,
        "ShahanshahiRojName": shahanshahiRojName,
        "ShahanshahiMahName": shahanshahiMahName,
        "ShahanshahiYear": shahanshahiYear,
        "KadmiDayId": kadmiDayId,
        "KadmiRojName": kadmiRojName,
        "KadmiMahName": kadmiMahName,
        "KadmiYear": kadmiYear,
        "FasliDayId": fasliDayId,
        "FasliRojName": fasliRojName,
        "FasliMahName": fasliMahName,
        "FasliYear": fasliYear,
      };
}
