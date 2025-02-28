import 'package:sensors_plus/sensors_plus.dart';
import '../domain/model/sensor_data.dart';
import '../port/out/sensors_port.dart';

class PhoneSensorsAdapter {
  static const samplingPeriod = Duration(milliseconds: 10);

  SensorsDataStreams get sensorsStreams => (
  accelerometerStream: userAccelerometerEventStream(
    samplingPeriod: samplingPeriod,
  ).map(_toSensorData<UserAccelerometerEvent>),

  gyroscopeStream: gyroscopeEventStream(
    samplingPeriod: samplingPeriod,
  ).map(_toSensorData<GyroscopeEvent>),

  magnetometerStream: magnetometerEventStream(
    samplingPeriod: samplingPeriod,
  ).map(_toSensorData<MagnetometerEvent>),
  );

  // SensorsDataStreams get sensorsStreams => (
  //   accelerometerStream: userAccelerometerEventStream(
  //     samplingPeriod: samplingPeriod,
  //   ).map(_toSensorData<UserAccelerometerEvent>),
  //
  //   gyroscopeStream: gyroscopeEventStream(
  //     samplingPeriod: samplingPeriod,
  //   ).map(_toSensorData<GyroscopeEvent>),
  //
  //   magnetometerStream: magnetometerEventStream(
  //     samplingPeriod: samplingPeriod,
  //   ).map(_toSensorData<MagnetometerEvent>),
  // );

  SensorData _toSensorData<T extends dynamic>(T event) => SensorData(
    x: event.x,
    y: event.y,
    z: event.z,
    timestamp: event.timestamp,
  );
}
