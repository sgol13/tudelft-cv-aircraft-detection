import 'dart:math';

import 'package:app/common.dart';
import 'package:app/domain/model/events/real_time_event.dart';
import 'package:vector_math/vector_math.dart';

class DeviceOrientationEvent extends RealTimeEvent {
  final double heading;
  final double pitch;
  final double roll;

  final Matrix3 rotationMatrix;

  DeviceOrientationEvent({
    required this.heading,
    required this.pitch,
    required this.roll,
    required this.rotationMatrix,
    required super.timestamp,
  });

  String get preview =>
      '[${formatValue(heading)}, ${formatValue(pitch)}, ${formatValue(roll)}]';

  static String formatValue(double value) =>
      radToDeg(value).toStringAsFixed(4).padLeft(8);
}
