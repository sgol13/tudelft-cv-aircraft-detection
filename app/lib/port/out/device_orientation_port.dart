import 'package:app/adapter/adsb_lol_api_adapter.dart';
import 'package:app/adapter/flutter_rotation_sensor_lib_adapter.dart';
import 'package:app/adapter/mock/mock_device_orientation_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/model/events/adsb_event.dart';
import '../../domain/model/events/device_orientation_event.dart';
import 'localization_port.dart';

part 'device_orientation_port.g.dart';

abstract class DeviceOrientationPort {
  Stream<DeviceOrientationEvent> get stream;
}

@riverpod
DeviceOrientationPort deviceOrientationPort(Ref ref) =>
    FlutterRotationSensorLibAdapter();