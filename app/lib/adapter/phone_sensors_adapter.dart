import 'package:rxdart/rxdart.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../domain/model/sensor_data.dart';
import '../port/out/sensors_port.dart';

class PhoneSensorsAdapter implements SensorsPort {
  // The sampling period is set not guaranteed on Android
  static const samplingPeriod = Duration(milliseconds: 30);

  @override
  SensorsDataStreams get sensorsStreams => (
    accelerometerStream: userAccelerometerEventStream(
          samplingPeriod: samplingPeriod,
        )
        .map(_toSensorData<UserAccelerometerEvent>),
        // .throttle((_) => Stream.periodic(Duration(seconds: 1))),

    gyroscopeStream: gyroscopeEventStream(
      samplingPeriod: samplingPeriod,
    ).map(_toSensorData<GyroscopeEvent>),

    magnetometerStream: magnetometerEventStream(
      samplingPeriod: samplingPeriod,
    ).map(_toSensorData<MagnetometerEvent>),
  );

  SensorData _toSensorData<T extends dynamic>(T event) => SensorData(
    x: event.x,
    y: event.y,
    z: event.z,
    timestamp: event.timestamp,
  );
}
