import 'package:app/domain/model/location.dart';
import 'package:app/port/out/adsb_api_port.dart';
import 'package:app/port/out/localization_port.dart';
import 'package:app/port/out/sensors_port.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'model/adsb_data.dart';
import 'model/sensor_data.dart';

part 'get_real_data_streams.g.dart';

typedef AllDataStreams =
    ({
      Stream<SensorData> accelerometerStream,
      Stream<SensorData> gyroscopeStream,
      Stream<SensorData> magnetometerStream,
      Stream<Location> localizationStream,
      Stream<AdsbData> adsbStream,
    });

class GetRealDataStreams {
  final SensorsPort _sensorsPort;
  final LocalizationPort _localizationPort;
  final AdsbApiPort _adsbApiPort;

  GetRealDataStreams(
    this._sensorsPort,
    this._localizationPort,
    this._adsbApiPort,
  );

  AllDataStreams get streams => (
    accelerometerStream: _sensorsPort.accelerometerStream(),
    gyroscopeStream: _sensorsPort.gyroscopeStream(),
    magnetometerStream: _sensorsPort.magnetometerStream(),
    localizationStream: _localizationPort.locationStream(),
    adsbStream: _adsbApiPort.adsbStream(),
  );
}

@riverpod
GetRealDataStreams getRealDataStreams(Ref ref) {
  final sensorsPort = ref.watch(sensorsPortProvider);
  final localizationPort = ref.watch(localizationPortProvider);
  final adsbApiPort = ref.watch(adsbApiPortProvider);

  return GetRealDataStreams(sensorsPort, localizationPort, adsbApiPort);
}
