import 'dart:convert';

import 'package:location/location.dart';
import 'package:sunrise_sunset/sunrise_sunset.dart';
import 'package:tuple/tuple.dart';

import 'database.dart';
import 'distance_provider.dart';
import 'models/sunrise_sunset_location_cache.dart';
import 'models/time_provider_result.dart';
import 'utilities.dart';

class TimeProvider {
  static Future<TimeProviderResult> getResult(DateTime dateTime) async {
    var sunriseSunsetTimeProvider =
        await SunriseSunsetTimeProvider.getResults(dateTime);
    DateTime sunrise = sunriseSunsetTimeProvider.sunrise;
    DateTime sunset = sunriseSunsetTimeProvider.sunset;

    DayPhase dayPhaseEnum;
    if (dateTime.isBefore(sunrise)) {
      dayPhaseEnum = DayPhase.beforeSunrise;
    } else if (dateTime.isBefore(sunset)) {
      dayPhaseEnum = DayPhase.day;
    } else {
      dayPhaseEnum = DayPhase.afterSunset;
    }

    int chogNumber = await _getChogNumber(dateTime, dayPhaseEnum);
    String dayPhase = (dayPhaseEnum == DayPhase.day) ? "Day" : "Night";

    return TimeProviderResult(
      dateTime: dateTime,
      geh: _getGeh(dateTime, sunrise, sunset),
      dayPhase: dayPhase,
      chogNumber: chogNumber,
    );
  }

  static Geh _getGeh(DateTime now, DateTime sunrise, DateTime sunset) {
    // For gah calculation
    final havanStart = sunrise.subtract(Duration(minutes: 36));
    final rapithwanStart = DateTime(now.year, now.month, now.day, 12, 0);
    final uzirenStart = DateTime(now.year, now.month, now.day, 15, 0);
    final aevishuthremStart = sunset;
    Geh result;
    if (now.isBefore(havanStart)) {
      result = Geh.ushahin;
    } else if (now.isBefore(rapithwanStart)) {
      result = Geh.havan;
    } else if (now.isBefore(uzirenStart)) {
      result = Geh.rapithwan;
    } else if (now.isBefore(aevishuthremStart)) {
      result = Geh.uzirin;
    } else {
      result = Geh.aevishuthrem;
    }
    return result;
  }

  static Future<int> _getChogNumber(
      DateTime dateTime, DayPhase dayPhase) async {
    // For Chaughadia calculation
    // There are 8 Chaughadia during day between sunrise and sunset,
    // and 8 Chaughadia during night between sunset and sunrise.

    // As we assume sunrise at 6:40 am and sunset at 6:40 pm, each Chaughadia is 90 min in duration

    var result = 0;
    DateTime phaseStart;
    DateTime phaseEnd;
    switch (dayPhase) {
      case DayPhase.beforeSunrise:
        var ssp = await SunriseSunsetTimeProvider.getResults(dateTime);
        var pssp = await SunriseSunsetTimeProvider.getResults(
            DateTime(dateTime.year, dateTime.month, dateTime.day - 1));
        phaseStart = pssp.sunset;
        phaseEnd = ssp.sunrise;
        break;
      case DayPhase.day:
        var ssp = await SunriseSunsetTimeProvider.getResults(dateTime);
        phaseStart = ssp.sunrise;
        phaseEnd = ssp.sunset;
        break;
      case DayPhase.afterSunset:
        var ssp = await SunriseSunsetTimeProvider.getResults(dateTime);
        var nssp = await SunriseSunsetTimeProvider.getResults(
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
}

enum DayPhase { beforeSunrise, day, afterSunset }

class SunriseSunsetTimeProvider {
  static Future<SunriseSunsetData> getResults(DateTime dateTime) async {
    final offset = dateTime.timeZoneOffset.toTimeZoneString();
    final date = dateTime.toString().substring(0, 10);
    final sunrise = "${date}T06:00:00$offset";
    final sunset = "${date}T18:00:00$offset";
    final noon = "${date}T12:00:00$offset";
    final defaultSunriseSunsetData = SunriseSunsetData.fromJSON(json.decode('''
      {    
        "sunrise":"$sunrise",
        "sunset":"$sunset",
        "solar_noon":"$noon",
        "day_length":432000,
        "civil_twilight_begin":"$sunrise",
        "civil_twilight_end":"$sunset",
        "nautical_twilight_begin":"$sunrise",
        "nautical_twilight_end":"$sunset",
        "astronomical_twilight_begin":"$sunrise",
        "astronomical_twilight_end":"$sunset"  
      }
      '''));

    var result = defaultSunriseSunsetData;

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    final location = Location();

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return result;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return result;
      }
    }

    locationData = await location.getLocation();

    final cache = (await DBProvider.db.getSunriseSunsetLocationCache(dateTime))
        .map((x) => Tuple2<double, SunriseSunsetLocationCache>(
            GreatCircleDistance.fromDegrees(
              latitude1: locationData.latitude!,
              longitude1: locationData.longitude!,
              latitude2: x.locationData.latitude!,
              longitude2: x.locationData.longitude!,
            ).vincentyDistance(),
            x))
        // Dont use if distance is greater than 27 km
        // This is expected to change times by 1 minute
        .where((x) => x.item1 < 27000)
        .toList();
    cache.sort((a, b) => a.item1.compareTo(b.item1));

    if (cache.isNotEmpty) {
      result = cache.first.item2.sunriseSunsetData;
    } else {
      final query = await SunriseSunset.getResults(
          date: dateTime,
          latitude: locationData.latitude,
          longitude: locationData.longitude);
      if (query!.success) {
        result = query.data!;
        await DBProvider.db
            .setSunriseSunsetLocationCache(SunriseSunsetLocationCache(
          date: dateTime,
          locationData: locationData,
          sunriseSunsetData: query.data!,
        ));
      }
    }

    return result;
  }
}
