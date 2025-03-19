import 'package:app/adapter/device_sensors_adapter.dart';
import 'package:app/domain/model/sensor_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sensors_port.g.dart';

abstract class SensorsPort {
  Stream<SensorData> accelerometerStream();

  Stream<SensorData> gyroscopeStream();

  Stream<SensorData> magnetometerStream();
}

@riverpod
SensorsPort sensorsPort(Ref ref) => DeviceSensorsAdapter();
