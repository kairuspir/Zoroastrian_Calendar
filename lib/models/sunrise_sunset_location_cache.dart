import 'dart:convert';

import 'package:location/location.dart';
import 'package:sunrise_sunset/sunrise_sunset.dart';

import '../utilities.dart';

SunriseSunsetLocationCache sunriseSunsetLocationCacheFromJson(String str) =>
    SunriseSunsetLocationCache.fromMap(json.decode(str));

String sunriseSunsetLocationCacheToJson(SunriseSunsetLocationCache data) =>
    json.encode(data.toMap());

class SunriseSunsetLocationCache {
  final DateTime date;
  final LocationData locationData;
  final SunriseSunsetData sunriseSunsetData;

  const SunriseSunsetLocationCache(
      {required this.date,
      required this.locationData,
      required this.sunriseSunsetData});

  SunriseSunsetLocationCache copyWith({
    DateTime? date,
    LocationData? locationData,
    SunriseSunsetData? sunriseSunsetData,
  }) {
    return SunriseSunsetLocationCache(
      date: date ?? this.date,
      locationData: locationData ?? this.locationData,
      sunriseSunsetData: sunriseSunsetData ?? this.sunriseSunsetData,
    );
  }

  factory SunriseSunsetLocationCache.fromMap(Map<String, dynamic> json) =>
      SunriseSunsetLocationCache(
        date: DateTime.parse(json["Date"]),
        locationData: locationDataFromJson(json["LocationData"]),
        sunriseSunsetData: sunriseSunsetDataFromJson(json["SunriseSunsetData"]),
      );

  Map<String, dynamic> toMap() => {
        "Date": date.toIso8601String(),
        "LocationData": locationDataToJson(locationData),
        "SunriseSunsetData": sunriseSunsetDataToJson(sunriseSunsetData),
      };
}
