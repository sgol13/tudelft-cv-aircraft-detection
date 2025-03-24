import 'package:app/domain/model/adsb_event.dart';
import 'package:app/domain/model/events/device_orientation_event.dart';
import 'package:app/domain/model/events/device_location_event.dart';
import 'package:app/domain/model/events/video_frame_event.dart';
import 'package:app/port/out/adsb_api_port.dart';
import 'package:app/port/out/camera_port.dart';
import 'package:app/port/out/device_orientation_port.dart';
import 'package:app/port/out/localization_port.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'get_data_streams.dart';

part 'get_real_data_streams.g.dart';

class GetRealDataStreams extends GetDataStreams {
  final DeviceOrientationPort _deviceOrientationPort;
  final LocalizationPort _localizationPort;
  final CameraPort _cameraPort;
  final AdsbApiPort _adsbApiPort;

  GetRealDataStreams(
    this._deviceOrientationPort,
    this._localizationPort,
    this._cameraPort,
    this._adsbApiPort,
  );

  @override
  Stream<DeviceOrientationEvent> get deviceOrientationStream =>
      _deviceOrientationPort.stream;

  @override
  Stream<DeviceLocationEvent> get deviceLocationStream =>
      _localizationPort.stream;

  @override
  Stream<VideoFrameEvent> get cameraStream => _cameraPort.stream;

  @override
  Stream<AdsbEvent> get adsbStream => _adsbApiPort.stream;
}

@riverpod
GetRealDataStreams getRealDataStreams(Ref ref) {
  final deviceOrientationPort = ref.watch(deviceOrientationPortProvider);
  final localizationPort = ref.watch(localizationPortProvider);
  final cameraPort = ref.watch(cameraPortProvider);
  final adsbApiPort = ref.watch(adsbApiPortProvider);

  return GetRealDataStreams(
    deviceOrientationPort,
    localizationPort,
    cameraPort,
    adsbApiPort,
  );
}
