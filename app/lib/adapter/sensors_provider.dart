import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorStreams {
  final Stream<AccelerometerEvent> accelerometer;
  final Stream<GyroscopeEvent> gyroscope;
  final Stream<MagnetometerEvent> magnetometer;

  SensorStreams({
    required this.accelerometer,
    required this.gyroscope,
    required this.magnetometer,
  });
}

final sensorsProvider = Provider<SensorStreams>((ref) {
  return SensorStreams(
    accelerometer: accelerometerEventStream(),
    gyroscope: gyroscopeEventStream(),
    magnetometer: magnetometerEventStream(),
  );
});

