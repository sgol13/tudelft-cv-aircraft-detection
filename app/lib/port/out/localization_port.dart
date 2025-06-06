import 'package:app/adapter/mock/mock_localization_adapter.dart';
import 'package:app/domain/model/events/device_location_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../adapter/gps_localization_adapter.dart';

part 'localization_port.g.dart';

abstract class LocalizationPort {
  Stream<DeviceLocationEvent> get stream;
}

@riverpod
LocalizationPort localizationPort(Ref ref) => GpsLocalizationAdapter();
