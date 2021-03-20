import 'dart:math';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:convert';

import 'package:sunrise_sunset/sunrise_sunset.dart';

import 'database.dart';
import 'models/enum_models.dart';
import 'models/zorastrian_date.dart';

extension myZorastrianDate on ZorastrianDate {
  int getDayId(String calendarName) => calendarPicker(
      calendarName, this.shahanshahiDayId, this.kadmiDayId, this.fasliDayId);

  String getRojName(String calendarName) => calendarPicker(calendarName,
      this.shahanshahiRojName, this.kadmiRojName, this.fasliRojName);

  String getMahName(String calendarName) => calendarPicker(calendarName,
      this.shahanshahiMahName, this.kadmiMahName, this.fasliMahName);

  int getYear(String calendarName) => calendarPicker(
      calendarName, this.shahanshahiYear, this.kadmiYear, this.fasliYear);
}

SunriseSunsetData sunriseSunsetDataFromJson(String str) =>
    SunriseSunsetData.fromJSON(json.decode(str));

String sunriseSunsetDataToJson(SunriseSunsetData data) =>
    json.encode(data.toMap());

extension mySunriseSunsetData on SunriseSunsetData {
  Map<String, dynamic> toMap() => {
        "sunrise": this.sunrise.toIso8601String(),
        "sunset": this.sunset.toIso8601String(),
        "solar_noon": this.solarNoon.toIso8601String(),
        "civil_twilight_begin": this.civilTwilightBegin.toIso8601String(),
        "civil_twilight_end": this.civilTwilightEnd.toIso8601String(),
        "nautical_twilight_begin": this.nauticalTwilightBegin.toIso8601String(),
        "nautical_twilight_end": this.nauticalTwilightEnd.toIso8601String(),
        "astronomical_twilight_begin":
            this.astronomicalTwilightBegin.toIso8601String(),
        "astronomical_twilight_end":
            this.astronomicalTwilightEnd.toIso8601String(),
        "day_length": this.dayLength,
      };
}

LocationData locationDataFromJson(String str) =>
    LocationData.fromMap(Map<String, double>.from(json.decode(str)));

String locationDataToJson(LocationData data) => json.encode(data.toMap());

extension myLocation on LocationData {
  Map<String, dynamic> toMap() => {
        "latitude": this.latitude,
        "longitude": this.longitude,
        "accuracy": this.accuracy,
        "altitude": this.altitude,
        "speed": this.speed,
        "speed_accuracy": this.speedAccuracy,
        "heading": this.heading,
        "time": this.time,
      };
}

extension MyDuration on Duration {
  String toTimeZoneString() {
    var sign = (inMicroseconds < 0) ? "-" : "+";
    var hours = this.inHours.abs().toString().padLeft(2, "0");
    var minutes = this.inMinutes.remainder(60).abs().toString().padLeft(2, "0");
    return sign + hours + ":" + minutes;
  }
}

extension MyDateTime on DateTime {}

extension MyTimeOfDay on TimeOfDay {
  double toDouble() {
    return this.hour + this.minute / 60.0;
  }
}

extension myDouble on double {
  TimeOfDay toTimeOfDay() {
    final doubleAsString = this.toString();
    final indexOfDecimal = doubleAsString.indexOf(".");

    int integerPart;
    double fractionalPart;
    if (indexOfDecimal != -1) {
      integerPart = int.parse(doubleAsString.substring(0, indexOfDecimal));
      fractionalPart = double.parse(doubleAsString.substring(indexOfDecimal));
    } else {
      integerPart = int.parse(doubleAsString);
      fractionalPart = 0;
    }
    final hour = integerPart;
    final minute = (fractionalPart * 60) as int;

    return TimeOfDay(hour: hour, minute: minute);
  }
}

extension myString on String {
  MaterialColor toMaterialColor() {
    switch (this) {
      case "red":
        return Colors.red;
      case "pink":
        return Colors.pink;
      case "purple":
        return Colors.purple;
      case "deepPurple":
        return Colors.deepPurple;
      case "indigo":
        return Colors.indigo;
      case "blue":
        return Colors.blue;
      case "lightBlue":
        return Colors.lightBlue;
      case "cyan":
        return Colors.cyan;
      case "teal":
        return Colors.teal;
      case "green":
        return Colors.green;
      case "lightGreen":
        return Colors.lightGreen;
      case "lime":
        return Colors.lime;
      case "yellow":
        return Colors.yellow;
      case "amber":
        return Colors.amber;
      case "orange":
        return Colors.orange;
      case "deepOrange":
        return Colors.deepOrange;
      case "brown":
        return Colors.brown;
      case "blueGrey":
        return Colors.blueGrey;
      case "grey":
      default:
        return Colors.grey;
    }
  }

  DeviceCalendarState toDeviceCalendarState() {
    switch (this) {
      case "NotInitialized":
        return DeviceCalendarState.NotInitialized;
      case "Disabled":
        return DeviceCalendarState.Disabled;
      default:
        return DeviceCalendarState.Initialized;
    }
  }
}

extension myMaterialColor on MaterialColor {
  String toMaterialColorName() {
    if (this == Colors.red) {
      return "red";
    } else if (this == Colors.pink) {
      return "pink";
    } else if (this == Colors.purple) {
      return "purple";
    } else if (this == Colors.deepPurple) {
      return "deepPurple";
    } else if (this == Colors.indigo) {
      return "indigo";
    } else if (this == Colors.blue) {
      return "blue";
    } else if (this == Colors.lightBlue) {
      return "lightBlue";
    } else if (this == Colors.cyan) {
      return "cyan";
    } else if (this == Colors.teal) {
      return "teal";
    } else if (this == Colors.green) {
      return "green";
    } else if (this == Colors.lightGreen) {
      return "lightGreen";
    } else if (this == Colors.lime) {
      return "lime";
    } else if (this == Colors.yellow) {
      return "yellow";
    } else if (this == Colors.amber) {
      return "amber";
    } else if (this == Colors.orange) {
      return "orange";
    } else if (this == Colors.deepOrange) {
      return "deepOrange";
    } else if (this == Colors.brown) {
      return "brown";
    } else if (this == Colors.blueGrey) {
      return "blueGrey";
    } else if (this == Colors.grey) {
      return "grey";
    } else {
      return "grey";
    }
  }
}

bool useWhiteForeground(Color color, {double bias: 1.0}) {
  // Old:
  // return 1.05 / (color.computeLuminance() + 0.05) > 4.5;

  // New:
  bias ??= 1.0;
  int v = sqrt(pow(color.red, 2) * 0.299 +
          pow(color.green, 2) * 0.587 +
          pow(color.blue, 2) * 0.114)
      .round();
  return v < 130 * bias ? true : false;
}

T calendarPicker<T>(String calendarName, T shahanshahiProperty, T kadmiProperty,
    T fasliProperty) {
  return (calendarName == DBProvider.calendar_key_shahenshai)
      ? shahanshahiProperty
      : (calendarName == DBProvider.calendar_key_kadmi)
          ? kadmiProperty
          : (calendarName == DBProvider.calendar_key_fasli)
              ? fasliProperty
              : null;
}
