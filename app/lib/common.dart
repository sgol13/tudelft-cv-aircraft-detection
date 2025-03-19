import 'dart:math';

DateTime maxTimestamp(DateTime t1, DateTime t2) => t1.isAfter(t2) ? t1 : t2;

DateTime minTimestamp(DateTime t1, DateTime t2) => t1.isBefore(t2) ? t1 : t2;

double degToRad(double degrees) => degrees * pi / 180;

double radToDeg(double radians) => radians * 180 / pi;