import 'dart:math';

import 'package:app/common.dart';
import 'package:app/domain/model/events/real_time_event.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';

class DeviceOrientationEvent extends RealTimeEvent {
  final OrientationEvent rawOrientation;

  final double heading;
  final double pitch;
  final double roll;

  DeviceOrientationEvent({
    required this.heading,
    required this.pitch,
    required this.roll,
    required super.timestamp,
    required this.rawOrientation,
  });

  String get preview =>
      '[${formatValue(heading)}, ${formatValue(pitch)}, ${formatValue(roll)}]';

  static String formatValue(double value) =>
      radToDeg(value).toStringAsFixed(4).padLeft(8);
}
