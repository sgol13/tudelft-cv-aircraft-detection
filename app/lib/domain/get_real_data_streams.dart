import 'package:app/domain/model/user_location.dart';
import 'package:app/port/out/localization_port.dart';
import 'package:app/port/out/sensors_port.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'model/sensor_data.dart';

part 'get_real_data_streams.g.dart';

typedef AllDataStreams = ({
  Stream<SensorData> accelerometerStream,
  Stream<SensorData> gyroscopeStream,
  Stream<SensorData> magnetometerStream,
  Stream<UserLocation> localizationStream,
});

class GetRealDataStreams {

  final SensorsPort _sensorsPort;
  final LocalizationPort _localizationPort;

  GetRealDataStreams(this._sensorsPort, this._localizationPort);

  AllDataStreams get streams => (
    accelerometerStream: _sensorsPort.sensorsStreams.accelerometerStream,
    gyroscopeStream: _sensorsPort.sensorsStreams.gyroscopeStream,
    magnetometerStream: _sensorsPort.sensorsStreams.magnetometerStream,
    localizationStream: _localizationPort.locationStream,
  );
}

@riverpod
GetRealDataStreams getRealDataStreams(Ref ref) {
  final sensorsPort = ref.watch(sensorsPortProvider);
  final localizationPort = ref.watch(localizationPortProvider);

  return GetRealDataStreams(sensorsPort, localizationPort);
}
