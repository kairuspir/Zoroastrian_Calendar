import 'dart:math';

import 'package:flutter/material.dart';

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
