import 'package:app/adapter/phone_sensors_adapter.dart';
import 'package:app/domain/model/sensor_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sensors_port.g.dart';

typedef SensorsDataStreams = ({
  Stream<SensorData> accelerometerStream,
  Stream<SensorData> gyroscopeStream,
  Stream<SensorData> magnetometerStream,
});

@riverpod
SensorsDataStreams sensorsStreamsPort(Ref ref) {
  return PhoneSensorsAdapter().sensorsStreams;
}