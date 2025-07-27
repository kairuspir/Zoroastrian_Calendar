import 'dart:math';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:convert';

import 'package:sunrise_sunset/sunrise_sunset.dart';

import 'database.dart';
import 'models/zorastrian_date.dart';

extension MyZorastrianDate on ZorastrianDate {
  int getDayId(String calendarName) =>
      calendarPicker(calendarName, shahanshahiDayId, kadmiDayId, fasliDayId);

  String getRojName(String calendarName) => calendarPicker(
      calendarName, shahanshahiRojName, kadmiRojName, fasliRojName);

  String getMahName(String calendarName) => calendarPicker(
      calendarName, shahanshahiMahName, kadmiMahName, fasliMahName);

  int getYear(String calendarName) =>
      calendarPicker(calendarName, shahanshahiYear, kadmiYear, fasliYear);
}

SunriseSunsetData sunriseSunsetDataFromJson(String str) =>
    SunriseSunsetData.fromJSON(json.decode(str));

String sunriseSunsetDataToJson(SunriseSunsetData data) =>
    json.encode(data.toMap());

extension MySunriseSunsetData on SunriseSunsetData {
  Map<String, dynamic> toMap() => {
        "sunrise": sunrise.toIso8601String(),
        "sunset": sunset.toIso8601String(),
        "solar_noon": solarNoon.toIso8601String(),
        "civil_twilight_begin": civilTwilightBegin.toIso8601String(),
        "civil_twilight_end": civilTwilightEnd.toIso8601String(),
        "nautical_twilight_begin": nauticalTwilightBegin.toIso8601String(),
        "nautical_twilight_end": nauticalTwilightEnd.toIso8601String(),
        "astronomical_twilight_begin":
            astronomicalTwilightBegin.toIso8601String(),
        "astronomical_twilight_end": astronomicalTwilightEnd.toIso8601String(),
        "day_length": dayLength,
      };
}

LocationData locationDataFromJson(String str) =>
    LocationData.fromMap(Map<String, double>.from(json.decode(str)));

String locationDataToJson(LocationData data) => json.encode(data.toMap());

extension MyLocation on LocationData {
  Map<String, dynamic> toMap() => {
        "latitude": latitude,
        "longitude": longitude,
        "accuracy": accuracy,
        "altitude": altitude,
        "speed": speed,
        "speed_accuracy": speedAccuracy,
        "heading": heading,
        "time": time,
      };
}

extension MyDuration on Duration {
  String toTimeZoneString() {
    var sign = (inMicroseconds < 0) ? "-" : "+";
    var hours = inHours.abs().toString().padLeft(2, "0");
    var minutes = inMinutes.remainder(60).abs().toString().padLeft(2, "0");
    return "$sign$hours:$minutes";
  }
}

extension MyDateTime on DateTime {
  bool isSameDate(DateTime otherDate) {
    return year == otherDate.year &&
        month == otherDate.month &&
        day == otherDate.day;
  }
}

extension MyTimeOfDay on TimeOfDay {
  double toDouble() {
    return hour + minute / 60.0;
  }
}

extension MyDouble on double {
  TimeOfDay toTimeOfDay() {
    final doubleAsString = toString();
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

extension MyString on String {
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

  int toMonthInt() {
    switch (this) {
      case "January":
        return 1;
      case "February":
        return 2;
      case "March":
        return 3;
      case "April":
        return 4;
      case "May":
        return 5;
      case "June":
        return 6;
      case "July":
        return 7;
      case "August":
        return 8;
      case "September":
        return 9;
      case "October":
        return 10;
      case "November":
        return 11;
      case "December":
        return 12;
      default:
        return 0;
    }
  }
}

extension MyMaterialColor on MaterialColor {
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

extension MyList<T> on List<T> {
  List<List<T>> chunk(int batchSize) {
    var len = length;
    var chunks = List<List<T>>.empty(growable: true);

    for (var i = 0; i < len; i += batchSize) {
      var end = (i + batchSize < len) ? i + batchSize : len;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }
}

bool useWhiteForeground(Color color, {double bias = 1.0}) {
  int v = sqrt(pow(color.r, 2) * 0.299 +
          pow(color.g, 2) * 0.587 +
          pow(color.b, 2) * 0.114)
      .round();
  return v < 130 * bias ? true : false;
}

T calendarPicker<T>(String calendarName, T shahanshahiProperty, T kadmiProperty,
    T fasliProperty) {
  assert(calendarName == DBProvider.calendarKeyShahenshai ||
      calendarName == DBProvider.calendarKeyKadmi ||
      calendarName == DBProvider.calendarKeyFasli);
  return (calendarName == DBProvider.calendarKeyShahenshai)
      ? shahanshahiProperty
      : (calendarName == DBProvider.calendarKeyKadmi)
          ? kadmiProperty
          : (calendarName == DBProvider.calendarKeyFasli)
              ? fasliProperty
              : throw Error();
}
