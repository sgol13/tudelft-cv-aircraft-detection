import 'package:app/domain/model/device_orientation_event.dart';
import 'package:app/domain/model/device_location_event.dart';
import 'package:app/port/out/adsb_api_port.dart';
import 'package:app/port/out/device_orientation_port.dart';
import 'package:app/port/out/localization_port.dart';
import 'package:app/port/out/sensors_port.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'get_data_streams.dart';
import 'model/adsb_data.dart';

part 'get_real_data_streams.g.dart';

class GetRealDataStreams extends GetDataStreams {
  final DeviceOrientationPort _deviceOrientationPort;
  final LocalizationPort _localizationPort;

  // final AdsbApiPort _adsbApiPort;

  GetRealDataStreams(
    this._deviceOrientationPort,
    this._localizationPort,
    // this._adsbApiPort,
  );

  @override
  Stream<DeviceOrientationEvent> get deviceOrientationStream =>
      _deviceOrientationPort.stream;

  @override
  Stream<DeviceLocationEvent> get locationStream => _localizationPort.stream;
}

@riverpod
GetRealDataStreams getRealDataStreams(Ref ref) {
  final deviceOrientationPort = ref.watch(deviceOrientationPortProvider);
  final localizationPort = ref.watch(localizationPortProvider);
  // final adsbApiPort = ref.watch(adsbApiPortProvider);

  return GetRealDataStreams(deviceOrientationPort, localizationPort);
}
