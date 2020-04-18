import 'package:flutter/material.dart';

class TimeProvider {
  final DateTime dateTime;

  // For gah calculation
  final midnight = TimeOfDay(hour: 0, minute: 40);
  final TimeOfDay sunrise;
  final noon = TimeOfDay(hour: 12, minute: 40);
  final afternoon = TimeOfDay(hour: 15, minute: 40);
  final TimeOfDay sunset;

  TimeProvider._(this.dateTime, this._dayPhase, this._chogNumber, this.sunrise,
      this.sunset);

  factory TimeProvider(DateTime dateTime) {
    var _sunriseSunsetTimeProvider = SunriseSunsetTimeProvider(dateTime);
    DateTime sunrise = _sunriseSunsetTimeProvider.sunrise;
    DateTime sunset = _sunriseSunsetTimeProvider.sunset;
    DayPhase dayPhase;
    if (dateTime.isBefore(sunrise)) {
      dayPhase = DayPhase.BeforeSunrise;
    } else if (dateTime.isBefore(sunset)) {
      dayPhase = DayPhase.Day;
    } else {
      dayPhase = DayPhase.AfterSunset;
    }

    int chogNumber = _getChogNumber(dateTime, dayPhase);

    return TimeProvider._(
      dateTime,
      dayPhase,
      chogNumber,
      TimeOfDay(hour: sunrise.hour, minute: sunrise.minute),
      TimeOfDay(hour: sunset.hour, minute: sunset.minute),
    );
  }

  // For Chaughadia calculation
  // There are 8 Chaughadia during day between sunrise and sunset,
  // and 8 Chaughadia during night between sunset and sunrise.

  // As we assume sunrise at 6:40 am and sunset at 6:40 pm, each Chaughadia is 90 min in duration

  /*final dayChaughadia1 = TimeOfDay(hour: 6, minute: 40);
  final dayChaughadia2 = TimeOfDay(hour: 8, minute: 10);
  final dayChaughadia3 = TimeOfDay(hour: 9, minute: 40);
  final dayChaughadia4 = TimeOfDay(hour: 11, minute: 10);
  final dayChaughadia5 = TimeOfDay(hour: 12, minute: 40);
  final dayChaughadia6 = TimeOfDay(hour: 14, minute: 10);
  final dayChaughadia7 = TimeOfDay(hour: 15, minute: 40);
  final dayChaughadia8 = TimeOfDay(hour: 17, minute: 10);

  final nightChaughadia1 = TimeOfDay(hour: 18, minute: 40);
  final nightChaughadia2 = TimeOfDay(hour: 20, minute: 10);
  final nightChaughadia3 = TimeOfDay(hour: 21, minute: 40);
  final nightChaughadia4 = TimeOfDay(hour: 23, minute: 10);
  final nightChaughadia5 = TimeOfDay(hour: 0, minute: 40);
  final nightChaughadia6 = TimeOfDay(hour: 2, minute: 10);
  final nightChaughadia7 = TimeOfDay(hour: 3, minute: 40);
  final nightChaughadia8 = TimeOfDay(hour: 5, minute: 10);*/

  final DayPhase _dayPhase;
  final int _chogNumber;

  String get dayPhase => (_dayPhase == DayPhase.Day) ? "Day" : "Night";

  int get chogNumber => _chogNumber;

  static int _getChogNumber(DateTime dateTime, DayPhase dayPhase) {
    var result = 0;
    DateTime phaseStart;
    DateTime phaseEnd;
    switch (dayPhase) {
      case DayPhase.BeforeSunrise:
        var ssp = SunriseSunsetTimeProvider(dateTime);
        var pssp = SunriseSunsetTimeProvider(
            DateTime(dateTime.year, dateTime.month, dateTime.day - 1));
        phaseStart = pssp.sunset;
        phaseEnd = ssp.sunrise;
        break;
      case DayPhase.Day:
        var ssp = SunriseSunsetTimeProvider(dateTime);
        phaseStart = ssp.sunrise;
        phaseEnd = ssp.sunset;
        break;
      case DayPhase.AfterSunset:
        var ssp = SunriseSunsetTimeProvider(dateTime);
        var nssp = SunriseSunsetTimeProvider(
            DateTime(dateTime.year, dateTime.month, dateTime.day + 1));
        phaseStart = ssp.sunset;
        phaseEnd = nssp.sunrise;
        break;
    }

    int milliseconds =
        ((phaseEnd.millisecondsSinceEpoch - phaseStart.millisecondsSinceEpoch) /
                8)
            .round();
    var duration = Duration(milliseconds: milliseconds);
    var chaug1 = phaseStart;
    var chaug2 = chaug1.add(duration);
    var chaug3 = chaug2.add(duration);
    var chaug4 = chaug3.add(duration);
    var chaug5 = chaug4.add(duration);
    var chaug6 = chaug5.add(duration);
    var chaug7 = chaug6.add(duration);
    var chaug8 = chaug7.add(duration);

    if (dateTime.isBefore(chaug2)) {
      result = 1;
    } else if (dateTime.isBefore(chaug3)) {
      result = 2;
    } else if (dateTime.isBefore(chaug4)) {
      result = 3;
    } else if (dateTime.isBefore(chaug5)) {
      result = 4;
    } else if (dateTime.isBefore(chaug6)) {
      result = 5;
    } else if (dateTime.isBefore(chaug7)) {
      result = 6;
    } else if (dateTime.isBefore(chaug8)) {
      result = 7;
    } else if (dateTime.isBefore(phaseEnd)) {
      result = 8;
    }
    return result;
  }
/*
  @deprecated
  int getChogNumber() {
    final timeOfDay = TimeOfDay.fromDateTime(this.dateTime).toDouble();
    var result = 0;
    switch (dayPhase) {
      case "Day":
        final dayChaughadia1 = this.dayChaughadia1.toDouble();
        final dayChaughadia2 = this.dayChaughadia2.toDouble();
        final dayChaughadia3 = this.dayChaughadia3.toDouble();
        final dayChaughadia4 = this.dayChaughadia4.toDouble();
        final dayChaughadia5 = this.dayChaughadia5.toDouble();
        final dayChaughadia6 = this.dayChaughadia6.toDouble();
        final dayChaughadia7 = this.dayChaughadia7.toDouble();
        final dayChaughadia8 = this.dayChaughadia8.toDouble();
        if (dayChaughadia1 <= timeOfDay && timeOfDay < dayChaughadia2) {
          result = 1;
        } else if (dayChaughadia2 <= timeOfDay && timeOfDay < dayChaughadia3) {
          result = 2;
        } else if (dayChaughadia3 <= timeOfDay && timeOfDay < dayChaughadia4) {
          result = 3;
        } else if (dayChaughadia4 <= timeOfDay && timeOfDay < dayChaughadia5) {
          result = 4;
        } else if (dayChaughadia5 <= timeOfDay && timeOfDay < dayChaughadia6) {
          result = 5;
        } else if (dayChaughadia6 <= timeOfDay && timeOfDay < dayChaughadia7) {
          result = 6;
        } else if (dayChaughadia7 <= timeOfDay && timeOfDay < dayChaughadia8) {
          result = 7;
        } else if (dayChaughadia8 <= timeOfDay) {
          result = 8;
        }

        break;
      case "Night":
        final nightChaughadia1 = this.nightChaughadia1.toDouble();
        final nightChaughadia2 = this.nightChaughadia2.toDouble();
        final nightChaughadia3 = this.nightChaughadia3.toDouble();
        final nightChaughadia4 = this.nightChaughadia4.toDouble();
        final nightChaughadia5 = this.nightChaughadia5.toDouble();
        final nightChaughadia6 = this.nightChaughadia6.toDouble();
        final nightChaughadia7 = this.nightChaughadia7.toDouble();
        final nightChaughadia8 = this.nightChaughadia8.toDouble();
        if (nightChaughadia1 <= timeOfDay && timeOfDay < nightChaughadia2) {
          result = 1;
        } else if (nightChaughadia2 <= timeOfDay &&
            timeOfDay < nightChaughadia3) {
          result = 2;
        } else if (nightChaughadia3 <= timeOfDay &&
            timeOfDay < nightChaughadia4) {
          result = 3;
        } else if ((nightChaughadia4 <= timeOfDay &&
                timeOfDay <= TimeOfDay(hour: 23, minute: 59).toDouble()) ||
            (TimeOfDay(hour: 0, minute: 0).toDouble() <= timeOfDay &&
                timeOfDay < nightChaughadia5)) {
          result = 4;
        } else if (nightChaughadia5 <= timeOfDay &&
            timeOfDay < nightChaughadia6) {
          result = 5;
        } else if (nightChaughadia6 <= timeOfDay &&
            timeOfDay < nightChaughadia7) {
          result = 6;
        } else if (nightChaughadia7 <= timeOfDay &&
            timeOfDay < nightChaughadia8) {
          result = 7;
        } else if (nightChaughadia8 <= timeOfDay) {
          result = 8;
        }
        break;
    }
    return result;
  }*/
}

enum DayPhase { BeforeSunrise, Day, AfterSunset }

class SunriseSunsetTimeProvider {
  DateTime dateTime;
  SunriseSunsetTimeProvider(this.dateTime);

  DateTime get sunrise => DateTime(
      this.dateTime.year, this.dateTime.month, this.dateTime.day, 6, 40);
  DateTime get sunset => DateTime(
      this.dateTime.year, this.dateTime.month, this.dateTime.day, 18, 40);
}
