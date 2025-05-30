import 'package:app/domain/model/events/device_location_event.dart';
import 'package:app/domain/model/geo_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../port/out/localization_port.dart';

class GpsLocalizationAdapter implements LocalizationPort {
  GpsLocalizationAdapter() {
    _requestLocationPermission();
  }

  @override
  Stream<DeviceLocationEvent> get stream => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    ),
  ).map(_toDeviceLocationEvent);

  DeviceLocationEvent _toDeviceLocationEvent(Position position) =>
      DeviceLocationEvent(
        geoLocation: GeoLocation(
          lat: position.latitude,
          lon: position.longitude,
          alt: position.altitude,
        ),
        timestamp: position.timestamp,
      );

  void _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }
}
