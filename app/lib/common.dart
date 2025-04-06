import 'dart:math';

DateTime maxTimestamp(List<DateTime> timestamps) =>
    timestamps.reduce((t1, t2) => t1.isAfter(t2) ? t1 : t2);

DateTime minTimestamp(List<DateTime> timestamps) =>
    timestamps.reduce((t1, t2) => t1.isBefore(t2) ? t1 : t2);

double degToRad(double degrees) => degrees * pi / 180;

double radToDeg(double radians) => radians * 180 / pi;

double feetToMeters(double feet) => feet * 0.3048;

double metersToFeet(double meters) => meters / 0.3048;