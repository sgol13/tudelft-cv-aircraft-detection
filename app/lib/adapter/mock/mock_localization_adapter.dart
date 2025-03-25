import 'package:app/domain/model/events/device_location_event.dart';
import 'package:app/port/out/localization_port.dart';

import '../../domain/model/geo_location.dart';

class MockLocalizationAdapter extends LocalizationPort {

  @override
  Stream<DeviceLocationEvent> get stream => Stream.value(DeviceLocationEvent(
    geoLocation: GeoLocation(
      lat: 52.006259,
      lon: 4.368762,
      alt: 50,
    ),
    timestamp: DateTime.now()
  ));
}